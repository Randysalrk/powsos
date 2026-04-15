using System;
using System.Data;
using System.Data.SqlClient;

namespace pow
{
    public partial class Raisealert : System.Web.UI.Page
    {
        db dbObj = new db();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }
            }
        }

        protected void btnSendNotification_Click(object sender, EventArgs e)
        {
            try
            {
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/Login.aspx");
                    return;
                }

                int userId = Convert.ToInt32(Session["UserId"]);

                decimal latitude;
                decimal longitude;

                if (!decimal.TryParse(hfLatitude.Value, out latitude) ||
                    !decimal.TryParse(hfLongitude.Value, out longitude))
                {
                    ShowMessage("Please select a valid location.");
                    return;
                }

                int alertId = SaveAlert(userId, latitude, longitude);
                int notifiedCount = NotifyNearbyOrganizations(alertId, latitude, longitude, 10.0);

                ShowMessage("Notification sent successfully to " + notifiedCount + " nearby organizations.");
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message.Replace("'", ""));
            }
        }

        private int SaveAlert(int userId, decimal latitude, decimal longitude)
        {
            int alertId = 0;

            using (SqlConnection con = dbObj.GetConnection())
            {
                string query = @"
                    INSERT INTO Alerts (UserId, Latitude, Longitude, CreatedAt, Status)
                    OUTPUT INSERTED.AlertId
                    VALUES (@UserId, @Latitude, @Longitude, GETDATE(), 'Active')";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@Latitude", latitude);
                    cmd.Parameters.AddWithValue("@Longitude", longitude);

                    con.Open();
                    object result = cmd.ExecuteScalar();

                    if (result != null)
                    {
                        alertId = Convert.ToInt32(result);
                    }
                }
            }

            return alertId;
        }

        private int NotifyNearbyOrganizations(int alertId, decimal lat, decimal lng, double radiusKm)
        {
            int count = 0;

            using (SqlConnection con = dbObj.GetConnection())
            {
                con.Open();

                string query = @"
                    SELECT UserId
                    FROM
                    (
                        SELECT 
                            UserId,
                            (
                                6371 * ACOS(
                                    COS(RADIANS(CAST(@Lat AS FLOAT))) *
                                    COS(RADIANS(CAST(Latitude AS FLOAT))) *
                                    COS(RADIANS(CAST(Longitude AS FLOAT)) - RADIANS(CAST(@Lng AS FLOAT))) +
                                    SIN(RADIANS(CAST(@Lat AS FLOAT))) *
                                    SIN(RADIANS(CAST(Latitude AS FLOAT)))
                                )
                            ) AS DistanceKm
                        FROM Users
                        WHERE UserType = 'Organization'
                          AND Latitude IS NOT NULL
                          AND Longitude IS NOT NULL
                          AND IsActive = 1
                    ) AS NearbyOrganizations
                    WHERE DistanceKm <= @RadiusKm";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Lat", lat);
                    cmd.Parameters.AddWithValue("@Lng", lng);
                    cmd.Parameters.AddWithValue("@RadiusKm", radiusKm);

                    DataTable dt = new DataTable();

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    foreach (DataRow row in dt.Rows)
                    {
                        int organizationUserId = Convert.ToInt32(row["UserId"]);
                        InsertNotification(con, alertId, organizationUserId);
                        count++;
                    }
                }
            }

            return count;
        }

        private void InsertNotification(SqlConnection con, int alertId, int organizationUserId)
        {
            string query = @"
                INSERT INTO AlertNotifications (AlertId, OrganizationUserId, IsSeen, SentAt)
                VALUES (@AlertId, @OrganizationUserId, 0, GETDATE())";

            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@AlertId", alertId);
                cmd.Parameters.AddWithValue("@OrganizationUserId", organizationUserId);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowMessage(string message)
        {
            string safeMessage = message.Replace("'", "\\'");
            string script = "alert('" + safeMessage + "');";
            ClientScript.RegisterStartupScript(this.GetType(), "msg", script, true);
        }
    }
}