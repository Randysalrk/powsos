using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace pow
{
    public partial class WebForm4 : System.Web.UI.Page
    {
        db dbobj = new db();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = "";
            }
        }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            try
            {
                string firstName = txtFirstName.Text.Trim();
                string lastName = txtLastName.Text.Trim();
                string username = txtUsername.Text.Trim();
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text.Trim();
                string confirmPassword = txtConfirmPassword.Text.Trim();

                // Always force organization
                string userType = "Organization";

                string nic = txtNIC.Text.Trim();
                string phone = txtMobile.Text.Trim();
                string locationText = txtLocation.Text.Trim();
                string latitudeText = hfLatitude.Value.Trim();
                string longitudeText = hfLongitude.Value.Trim();

                if (string.IsNullOrWhiteSpace(firstName) ||
                    string.IsNullOrWhiteSpace(lastName) ||
                    string.IsNullOrWhiteSpace(username) ||
                    string.IsNullOrWhiteSpace(email) ||
                    string.IsNullOrWhiteSpace(password) ||
                    string.IsNullOrWhiteSpace(confirmPassword) ||
                    string.IsNullOrWhiteSpace(nic) ||
                    string.IsNullOrWhiteSpace(phone))
                {
                    ShowSweetAlert("Validation Error", "Please fill all required fields.", "warning");
                    return;
                }

                if (password != confirmPassword)
                {
                    ShowSweetAlert("Validation Error", "Password and confirm password do not match.", "error");
                    return;
                }

                decimal? latitude = null;
                decimal? longitude = null;

                if (!string.IsNullOrWhiteSpace(latitudeText))
                {
                    if (decimal.TryParse(latitudeText, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal lat))
                    {
                        latitude = lat;
                    }
                }

                if (!string.IsNullOrWhiteSpace(longitudeText))
                {
                    if (decimal.TryParse(longitudeText, NumberStyles.Any, CultureInfo.InvariantCulture, out decimal lng))
                    {
                        longitude = lng;
                    }
                }

                string profileImagePath = null;

                if (fileProfile.HasFile)
                {
                    string extension = Path.GetExtension(fileProfile.FileName).ToLower();

                    if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
                    {
                        ShowSweetAlert("Invalid File", "Only JPG, JPEG, and PNG files are allowed.", "error");
                        return;
                    }

                    string folderPath = Server.MapPath("~/Uploads/ProfileImages/");
                    if (!Directory.Exists(folderPath))
                    {
                        Directory.CreateDirectory(folderPath);
                    }

                    string fileName = Guid.NewGuid().ToString() + extension;
                    string fullPath = Path.Combine(folderPath, fileName);
                    fileProfile.SaveAs(fullPath);

                    profileImagePath = "~/Uploads/ProfileImages/" + fileName;
                }

                string passwordHash = HashPassword(password);

                using (SqlConnection con = dbobj.GetConnection())
                {
                    con.Open();

                    string checkQuery = "SELECT COUNT(*) FROM Users WHERE Username = @Username OR Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                    {
                        checkCmd.Parameters.Add("@Username", SqlDbType.NVarChar, 50).Value = username;
                        checkCmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;

                        int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                        if (exists > 0)
                        {
                            ShowSweetAlert("Already Exists", "Username or Email already exists.", "info");
                            return;
                        }
                    }

                    string insertQuery = @"
                        INSERT INTO Users
                        (
                            Username,
                            Email,
                            PasswordHash,
                            FirstName,
                            LastName,
                            NIC,
                            Phone,
                            UserType,
                            LocationText,
                            Latitude,
                            Longitude,
                            ProfileImagePath,
                            CreatedAt,
                            IsActive
                        )
                        VALUES
                        (
                            @Username,
                            @Email,
                            @PasswordHash,
                            @FirstName,
                            @LastName,
                            @NIC,
                            @Phone,
                            @UserType,
                            @LocationText,
                            @Latitude,
                            @Longitude,
                            @ProfileImagePath,
                            GETDATE(),
                            1
                        )";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.Add("@Username", SqlDbType.NVarChar, 50).Value = username;
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 100).Value = email;
                        cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = passwordHash;
                        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = GetDbValue(firstName);
                        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = GetDbValue(lastName);
                        cmd.Parameters.Add("@NIC", SqlDbType.NVarChar, 20).Value = GetDbValue(nic);
                        cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 20).Value = GetDbValue(phone);
                        cmd.Parameters.Add("@UserType", SqlDbType.NVarChar, 20).Value = userType;
                        cmd.Parameters.Add("@LocationText", SqlDbType.NVarChar, 255).Value = GetDbValue(locationText);

                        SqlParameter latParam = new SqlParameter("@Latitude", SqlDbType.Decimal);
                        latParam.Precision = 10;
                        latParam.Scale = 8;
                        latParam.Value = latitude.HasValue ? (object)latitude.Value : DBNull.Value;
                        cmd.Parameters.Add(latParam);

                        SqlParameter lngParam = new SqlParameter("@Longitude", SqlDbType.Decimal);
                        lngParam.Precision = 11;
                        lngParam.Scale = 8;
                        lngParam.Value = longitude.HasValue ? (object)longitude.Value : DBNull.Value;
                        cmd.Parameters.Add(lngParam);

                        cmd.Parameters.Add("@ProfileImagePath", SqlDbType.NVarChar, 255).Value =
                            string.IsNullOrWhiteSpace(profileImagePath) ? (object)DBNull.Value : profileImagePath;

                        int result = cmd.ExecuteNonQuery();

                        if (result > 0)
                        {
                            ClearFields();
                            ShowSweetAlertWithRedirect("Success", "Organization user created successfully.", "success", "Login.aspx");
                        }
                        else
                        {
                            ShowSweetAlert("Failed", "Signup failed.", "error");
                        }
                    }
                }
            }
            catch (SqlException ex)
            {
                ShowSweetAlert("Database Error", ex.Message.Replace("'", "\\'"), "error");
            }
            catch (Exception ex)
            {
                ShowSweetAlert("Error", ex.Message.Replace("'", "\\'"), "error");
            }
        }

        private object GetDbValue(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value;
        }

        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.UTF8.GetBytes(password);
                byte[] hashBytes = sha256.ComputeHash(bytes);
                StringBuilder sb = new StringBuilder();

                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("x2"));
                }

                return sb.ToString();
            }
        }

        private void ShowSweetAlert(string title, string message, string icon)
        {
            string script = $@"
                Swal.fire({{
                    title: '{title}',
                    text: '{message}',
                    icon: '{icon}',
                    confirmButtonText: 'OK'
                }});";

            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), script, true);
        }

        private void ShowSweetAlertWithRedirect(string title, string message, string icon, string redirectUrl)
        {
            string script = $@"
                Swal.fire({{
                    title: '{title}',
                    text: '{message}',
                    icon: '{icon}',
                    confirmButtonText: 'OK'
                }}).then((result) => {{
                    if (result.isConfirmed) {{
                        window.location = '{redirectUrl}';
                    }}
                }});";

            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), script, true);
        }

        private void ClearFields()
        {
            txtFirstName.Text = "";
            txtLastName.Text = "";
            txtUsername.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            txtNIC.Text = "";
            txtMobile.Text = "";
            txtLocation.Text = "";
            hfLatitude.Value = "";
            hfLongitude.Value = "";
            lblLocationStatus.Text = "Click 'Get Current Location' or select on map.";
        }
    }
}