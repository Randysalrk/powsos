using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace pow
{
    public partial class Login : System.Web.UI.Page
    {
        db dbObj = new db();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // If already logged in, go to dashboard
                if (Session["UserId"] != null)
                {
                    Response.Redirect("~/Dashboard.aspx");
                    return;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string loginInput = txtEmail.Text.Trim();
                string password = txtPassword.Text.Trim();

                if (string.IsNullOrWhiteSpace(loginInput) || string.IsNullOrWhiteSpace(password))
                {
                    ShowMessage("Please enter username/email and password.");
                    return;
                }

                string hashedPassword = GetSha256Hash(password);

                using (SqlConnection con = dbObj.GetConnection())
                {
                    string query = @"
                        SELECT TOP 1
                            UserId,
                            Username,
                            Email,
                            UserType,
                            FirstName,
                            LastName,
                            IsActive
                        FROM Users
                        WHERE
                            (
                                LOWER(LTRIM(RTRIM(Username))) = LOWER(LTRIM(RTRIM(@LoginInput)))
                                OR LOWER(LTRIM(RTRIM(Email))) = LOWER(LTRIM(RTRIM(@LoginInput)))
                            )
                            AND PasswordHash = @PasswordHash
                            AND IsActive = 1";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@LoginInput", loginInput);
                        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                        con.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["UserId"] = reader["UserId"].ToString();
                                Session["Username"] = reader["Username"].ToString();
                                Session["Email"] = reader["Email"].ToString();
                                Session["UserType"] = reader["UserType"].ToString();
                                Session["FirstName"] = reader["FirstName"] != DBNull.Value ? reader["FirstName"].ToString() : "";
                                Session["LastName"] = reader["LastName"] != DBNull.Value ? reader["LastName"].ToString() : "";

                                Response.Redirect("~/Dashboard.aspx");
                            }
                            else
                            {
                                ShowMessage("Invalid username/email or password.");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message.Replace("'", ""));
            }
        }

        private string GetSha256Hash(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                StringBuilder builder = new StringBuilder();

                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2"));
                }

                return builder.ToString();
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