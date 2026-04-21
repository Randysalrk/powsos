using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

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
                pnlModal.Visible = false;
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
                            n.OrganizationUserId,
                            n.IsSeen,
                            n.SentAt,
                            ISNULL(n.NotificationStatus, 'Pending') AS NotificationStatus,
                            LTRIM(RTRIM(ISNULL(u.FirstName,''))) +
                            CASE 
                                WHEN ISNULL(u.LastName,'') = '' THEN ''
                                ELSE ' ' + LTRIM(RTRIM(ISNULL(u.LastName,''))
                            END AS RaisedByName
                        FROM AlertNotifications n
                        INNER JOIN Alerts a ON n.AlertId = a.AlertId
                        INNER JOIN Users u ON a.UserId = u.UserId
                        WHERE n.OrganizationUserId = @OrganizationUserId
                          AND ISNULL(n.NotificationStatus, 'Pending') IN ('Pending', 'Accepted', 'Successful', 'Unsuccessful')
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
                Response.Write("<script>alert('Error loading notifications: " + ex.Message.Replace("'", "") + "');</script>");
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
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
                            ISNULL(n.NotificationStatus, 'Pending') AS NotificationStatus,
                            a.Description,
                            a.AnimalType,
                            a.LocationText,
                            a.Latitude,
                            a.Longitude,
                            LTRIM(RTRIM(ISNULL(u.FirstName,''))) +
                            CASE 
                                WHEN ISNULL(u.LastName,'') = '' THEN ''
                                ELSE ' ' + LTRIM(RTRIM(ISNULL(u.LastName,''))
                            END AS RaisedByName
                        FROM AlertNotifications n
                        INNER JOIN Alerts a ON n.AlertId = a.AlertId
                        INNER JOIN Users u ON a.UserId = u.UserId
                        WHERE n.NotificationId = @NotificationId
                          AND n.OrganizationUserId = @OrganizationUserId";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        cmd.Parameters.AddWithValue("@OrganizationUserId", orgUserId);

                        con.Open();
                        SqlDataReader dr = cmd.ExecuteReader();

                        if (dr.Read())
                        {
                            hfNotificationId.Value = dr["NotificationId"].ToString();
                            hfAlertId.Value = dr["AlertId"].ToString();

                            lblAlertId.Text = dr["AlertId"].ToString();
                            lblRaisedBy.Text = dr["RaisedByName"].ToString();
                            lblDescription.Text = dr["Description"] == DBNull.Value ? "-" : dr["Description"].ToString();
                            lblAnimalType.Text = dr["AnimalType"] == DBNull.Value ? "-" : dr["AnimalType"].ToString();
                            lblLocationText.Text = dr["LocationText"] == DBNull.Value ? "-" : dr["LocationText"].ToString();
                            lblLatitude.Text = dr["Latitude"] == DBNull.Value ? "-" : dr["Latitude"].ToString();
                            lblLongitude.Text = dr["Longitude"] == DBNull.Value ? "-" : dr["Longitude"].ToString();
                            lblSentTime.Text = Convert.ToDateTime(dr["SentAt"]).ToString("yyyy-MM-dd hh:mm tt");

                            pnlModal.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>alert('Error loading details: " + ex.Message.Replace("'", "") + "');</script>");
            }
        }

        protected void btnAccept_Click(object sender, EventArgs e)
        {
            try
            {
                int orgUserId = Convert.ToInt32(Session["UserId"]);
                int notificationId = Convert.ToInt32(hfNotificationId.Value);
                int alertId = Convert.ToInt32(hfAlertId.Value);

                using (SqlConnection con = dbObj.GetConnection())
                {
                    con.Open();
                    SqlTransaction tran = con.BeginTransaction();

                    try
                    {
                        string acceptQuery = @"
                            UPDATE AlertNotifications
                            SET NotificationStatus = 'Accepted',
                                ActionAt = GETDATE(),
                                AssignedAt = GETDATE(),
                                IsSeen = 1
                            WHERE NotificationId = @NotificationId
                              AND OrganizationUserId = @OrganizationUserId
                              AND ISNULL(NotificationStatus, 'Pending') = 'Pending'";

                        using (SqlCommand cmd = new SqlCommand(acceptQuery, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                            cmd.Parameters.AddWithValue("@OrganizationUserId", orgUserId);
                            int affected = cmd.ExecuteNonQuery();

                            if (affected == 0)
                                throw new Exception("This notification is already handled.");
                        }

                        string cancelOthersQuery = @"
                            UPDATE AlertNotifications
                            SET NotificationStatus = 'Cancelled',
                                ActionAt = GETDATE()
                            WHERE AlertId = @AlertId
                              AND NotificationId <> @NotificationId
                              AND ISNULL(NotificationStatus, 'Pending') = 'Pending'";

                        using (SqlCommand cmd = new SqlCommand(cancelOthersQuery, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@AlertId", alertId);
                            cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                            cmd.ExecuteNonQuery();
                        }

                        string alertUpdateQuery = @"
                            UPDATE Alerts
                            SET AlertStatus = 'Assigned'
                            WHERE AlertId = @AlertId";

                        using (SqlCommand cmd = new SqlCommand(alertUpdateQuery, con, tran))
                        {
                            cmd.Parameters.AddWithValue("@AlertId", alertId);
                            cmd.ExecuteNonQuery();
                        }

                        tran.Commit();

                        Response.Redirect("~/AlertMap.aspx?alertId=" + alertId + "&notificationId=" + notificationId);
                    }
                    catch
                    {
                        tran.Rollback();
                        throw;
                    }
                }
            }
            catch (Exception ex)
            {
                pnlModal.Visible = true;
                Response.Write("<script>alert('Accept failed: " + ex.Message.Replace("'", "") + "');</script>");
            }
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            try
            {
                int orgUserId = Convert.ToInt32(Session["UserId"]);
                int notificationId = Convert.ToInt32(hfNotificationId.Value);

                using (SqlConnection con = dbObj.GetConnection())
                {
                    string query = @"
                        UPDATE AlertNotifications
                        SET NotificationStatus = 'Rejected',
                            ActionAt = GETDATE(),
                            IsSeen = 1
                        WHERE NotificationId = @NotificationId
                          AND OrganizationUserId = @OrganizationUserId
                          AND ISNULL(NotificationStatus, 'Pending') = 'Pending'";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@NotificationId", notificationId);
                        cmd.Parameters.AddWithValue("@OrganizationUserId", orgUserId);

                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                pnlModal.Visible = false;
                LoadNotifications();
            }
            catch (Exception ex)
            {
                pnlModal.Visible = true;
                Response.Write("<script>alert('Reject failed: " + ex.Message.Replace("'", "") + "');</script>");
            }
        }

        protected void btnClose_Click(object sender, EventArgs e)
        {
            pnlModal.Visible = false;
        }
    }
}