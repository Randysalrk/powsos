using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

namespace pow
{
    public partial class Notifications : System.Web.UI.Page
    {
        db dbObj = new db();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                pnlDetails.Visible = false;
                LoadNotifications();
            }
        }

        private void LoadNotifications()
        {
            try
            {
                int orgUserId = Convert.ToInt32(Session["UserId"]);

                using (SqlConnection con = dbObj.GetConnection())
                {
                    string query = @"
                        SELECT 
                            n.NotificationId,
                            n.AlertId,
                            n.IsSeen,
                            n.SentAt,
                            LTRIM(RTRIM(ISNULL(u.FirstName,''))) +
                            CASE 
                                WHEN ISNULL(u.LastName,'') = '' THEN ''
                                ELSE ' ' + LTRIM(RTRIM(ISNULL(u.LastName,'')))
                            END AS RaisedByName
                        FROM AlertNotifications n
                        INNER JOIN Alerts a ON n.AlertId = a.AlertId
                        INNER JOIN Users u ON a.UserId = u.UserId
                        WHERE n.OrganizationUserId = @OrganizationUserId
                        ORDER BY n.SentAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@OrganizationUserId", orgUserId);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            rptNotifications.DataSource = dt;
                            rptNotifications.DataBind();

                            pnlEmpty.Visible = dt.Rows.Count == 0;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading notifications: " + ex.Message.Replace("'", ""));
            }
        }

        protected void rptNotifications_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewNotification")
            {
                int notificationId = Convert.ToInt32(e.CommandArgument);
                LoadNotificationDetails(notificationId);
            }
        }

        private void LoadNotificationDetails(int notificationId)
        {
            try
            {
                int orgUserId = Convert.ToInt32(Session["UserId"]);

                using (SqlConnection con = dbObj.GetConnection())
                {
                    string query = @"
                        SELECT TOP 1
                            n.NotificationId,
                            n.AlertId,
                            n.SentAt,
                            org.UserId AS OrgUserId,
                            org.Username AS OrgUsername,
                            org.LocationText AS OrgLocationText,
                            org.Latitude AS OrgLatitude,
                            org.Longitude AS OrgLongitude,
                            a.Latitude AS AlertLatitude,
                            a.Longitude AS AlertLongitude,
                            raised.Username AS RaisedUsername,
                            ISNULL(raised.FirstName,'') + 
                            CASE 
                                WHEN ISNULL(raised.LastName,'') = '' THEN ''
                                ELSE ' ' + ISNULL(raised.LastName,'')
                            END AS RaisedFullName
                        FROM AlertNotifications n
                        INNER JOIN Alerts a ON n.AlertId = a.AlertId
                        INNER JOIN Users org ON n.OrganizationUserId = org.UserId
                        INNER JOIN Users raised ON a.UserId = raised.UserId
                        WHERE n.NotificationId = @NotificationId
                          AND n.OrganizationUserId = @OrganizationUserId";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        cmd.Parameters.AddWithValue("@OrganizationUserId", orgUserId);

                        con.Open();

                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string orgName = dr["OrgUsername"] != DBNull.Value ? dr["OrgUsername"].ToString() : "";
                                string orgLocation = dr["OrgLocationText"] != DBNull.Value ? dr["OrgLocationText"].ToString() : "";
                                string raisedBy = dr["RaisedFullName"] != DBNull.Value ? dr["RaisedFullName"].ToString().Trim() : "";
                                string raisedUsername = dr["RaisedUsername"] != DBNull.Value ? dr["RaisedUsername"].ToString() : "";

                                decimal orgLat = dr["OrgLatitude"] != DBNull.Value ? Convert.ToDecimal(dr["OrgLatitude"]) : 0;
                                decimal orgLng = dr["OrgLongitude"] != DBNull.Value ? Convert.ToDecimal(dr["OrgLongitude"]) : 0;
                                decimal alertLat = dr["AlertLatitude"] != DBNull.Value ? Convert.ToDecimal(dr["AlertLatitude"]) : 0;
                                decimal alertLng = dr["AlertLongitude"] != DBNull.Value ? Convert.ToDecimal(dr["AlertLongitude"]) : 0;

                                if (orgLat == 0 || orgLng == 0 || alertLat == 0 || alertLng == 0)
                                {
                                    pnlDetails.Visible = false;
                                    ShowMessage("Invalid organization or alert coordinates.");
                                    return;
                                }

                                lblOrganizationName.Text = orgName;

                                lblOrganizationLocation.Text = string.IsNullOrWhiteSpace(orgLocation)
                                    ? orgLat.ToString("0.000000") + ", " + orgLng.ToString("0.000000")
                                    : orgLocation + " (" + orgLat.ToString("0.000000") + ", " + orgLng.ToString("0.000000") + ")";

                                if (string.IsNullOrWhiteSpace(raisedBy))
                                {
                                    raisedBy = raisedUsername;
                                }

                                lblRaisedBy.Text = raisedBy;
                                lblAlertLocation.Text = alertLat.ToString("0.000000") + ", " + alertLng.ToString("0.000000");
                                lblSentTime.Text = Convert.ToDateTime(dr["SentAt"]).ToString("yyyy-MM-dd hh:mm tt");

                                hfOrgLat.Value = orgLat.ToString(CultureInfo.InvariantCulture);
                                hfOrgLng.Value = orgLng.ToString(CultureInfo.InvariantCulture);
                                hfAlertLat.Value = alertLat.ToString(CultureInfo.InvariantCulture);
                                hfAlertLng.Value = alertLng.ToString(CultureInfo.InvariantCulture);

                                // Fallback straight-line distance shown first; JS will replace with road distance.
                                double fallbackDistance = GetDistanceKm(
                                    Convert.ToDouble(orgLat),
                                    Convert.ToDouble(orgLng),
                                    Convert.ToDouble(alertLat),
                                    Convert.ToDouble(alertLng)
                                );

                                lblDistance.Text = fallbackDistance.ToString("0.00") + " km (air distance)";
                                pnlDetails.Visible = true;
                            }
                            else
                            {
                                pnlDetails.Visible = false;
                                ShowMessage("Notification details not found.");
                                return;
                            }
                        }
                    }
                }

                MarkNotificationAsSeen(notificationId);
                LoadNotifications();

                ScriptManager.RegisterStartupScript(
                    this,
                    this.GetType(),
                    "loadMap",
                    "setTimeout(function(){ loadNotificationMap(); }, 300);",
                    true
                );
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading notification details: " + ex.Message.Replace("'", ""));
            }
        }

        private void MarkNotificationAsSeen(int notificationId)
        {
            using (SqlConnection con = dbObj.GetConnection())
            {
                string query = @"
                    UPDATE AlertNotifications
                    SET IsSeen = 1
                    WHERE NotificationId = @NotificationId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private double GetDistanceKm(double lat1, double lng1, double lat2, double lng2)
        {
            double R = 6371.0;
            double dLat = ToRadians(lat2 - lat1);
            double dLng = ToRadians(lng2 - lng1);

            double a =
                Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                Math.Sin(dLng / 2) * Math.Sin(dLng / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

            return R * c;
        }

        private double ToRadians(double angle)
        {
            return angle * (Math.PI / 180);
        }

        private void ShowMessage(string message)
        {
            string safeMessage = message.Replace("'", "\\'");
            string script = "alert('" + safeMessage + "');";
            ClientScript.RegisterStartupScript(this.GetType(), "msg", script, true);
        }
    }
}