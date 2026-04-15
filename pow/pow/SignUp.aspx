<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="pow.SignUp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Signup</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

    <style>
        body {
            margin: 0;
            padding: 0;
            background: #efefef;
            font-family: Arial, sans-serif;
        }

        .signup-wrapper {
            width: 360px;
            margin: 0 auto;
            padding: 20px 12px;
            box-sizing: border-box;
            background: #efefef;
            min-height: 100vh;
        }

        .logo-text {
            text-align: center;
            font-size: 28px;
            font-weight: bold;
            color: #d89100;
            margin-bottom: 20px;
        }

        .title {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 12px;
            color: #111;
        }

        .upload-box {
            width: 80px;
            height: 60px;
            background: #d9d9d9;
            border-radius: 8px;
            color: #777;
            font-size: 12px;
            text-align: center;
            padding-top: 12px;
            box-sizing: border-box;
            margin-bottom: 6px;
        }

        .file-upload {
            margin-bottom: 10px;
        }

        .row-2 {
            display: flex;
            gap: 6px;
        }

        .input-box, .dropdown-box, .btn-location, .btn-signup {
            width: 100%;
            height: 40px;
            margin-bottom: 8px;
            border: none;
            border-radius: 4px;
            box-sizing: border-box;
            padding: 0 10px;
            font-size: 14px;
            outline: none;
        }

        .input-box, .dropdown-box {
            background: #eaf2ff;
        }

        .map-box {
            width: 100%;
            height: 240px;
            border-radius: 4px;
            margin-bottom: 8px;
            overflow: hidden;
            border: 1px solid #d0d0d0;
        }

        .location-status {
            font-size: 13px;
            color: #666;
            margin-bottom: 8px;
            display: block;
        }

        .map-help {
            font-size: 12px;
            color: #666;
            margin-bottom: 8px;
        }

        .btn-location {
            background: #f3f3f3;
            cursor: pointer;
        }

        .btn-signup {
            background: #eab23c;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
        }

        .preview-img {
            width: 80px;
            height: 60px;
            border-radius: 8px;
            object-fit: cover;
            display: none;
            margin-bottom: 6px;
            border: 1px solid #ccc;
        }
    </style>

    <script type="text/javascript">
        var map;
        var marker;

        function initMap() {
            map = L.map('mapPreview').setView([6.9271, 79.8612], 12); // Colombo default

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(map);

            map.on('click', function (e) {
                setLocationValues(e.latlng.lat, e.latlng.lng, "Location selected from map.");
            });

            setTimeout(function () {
                map.invalidateSize();
            }, 300);
        }

        function setLocationValues(lat, lng, statusMessage) {
            var txtLocation = document.getElementById('<%= txtLocation.ClientID %>');
            var hfLat = document.getElementById('<%= hfLatitude.ClientID %>');
            var hfLng = document.getElementById('<%= hfLongitude.ClientID %>');
            var status = document.getElementById('<%= lblLocationStatus.ClientID %>');

            hfLat.value = lat.toFixed(8);
            hfLng.value = lng.toFixed(8);
            txtLocation.value = lat.toFixed(6) + ", " + lng.toFixed(6);
            status.innerHTML = statusMessage;

            if (marker) {
                marker.setLatLng([lat, lng]);
            } else {
                marker = L.marker([lat, lng]).addTo(map);
            }

            map.setView([lat, lng], 16);
        }

        function getCurrentLocation() {
            var status = document.getElementById('<%= lblLocationStatus.ClientID %>');

            if (!navigator.geolocation) {
                status.innerHTML = "Geolocation is not supported by this browser.";
                Swal.fire("Location Error", "Geolocation is not supported by this browser.", "error");
                return;
            }

            status.innerHTML = "Getting current location...";

            navigator.geolocation.getCurrentPosition(
                function (position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;

                    setLocationValues(lat, lng, "Current location fetched successfully.");

                    Swal.fire({
                        icon: "success",
                        title: "Location Found",
                        text: "Current location fetched successfully."
                    });
                },
                function (error) {
                    var msg = "";

                    switch (error.code) {
                        case error.PERMISSION_DENIED:
                            msg = "Location permission denied.";
                            break;
                        case error.POSITION_UNAVAILABLE:
                            msg = "Location unavailable. Please click on the map to choose location manually.";
                            break;
                        case error.TIMEOUT:
                            msg = "Location request timed out. Please click on the map to choose location manually.";
                            break;
                        default:
                            msg = "Unable to get current location. Please click on the map to choose location manually.";
                            break;
                    }

                    status.innerHTML = msg;

                    Swal.fire({
                        icon: "warning",
                        title: "Location Not Found",
                        text: msg
                    });
                },
                {
                    enableHighAccuracy: true,
                    timeout: 45000,
                    maximumAge: 300000
                }
            );
        }

        function previewProfileImage(input) {
            var preview = document.getElementById('imgPreview');

            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                    preview.style.display = "block";
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        window.onload = function () {
            initMap();
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="signup-wrapper">
            <div class="logo-text">PawSOS</div>
            <div class="title">Signup</div>

            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

            <img id="imgPreview" class="preview-img" alt="Profile Preview" />
            <div class="upload-box">Upload<br />profile pic<br />here</div>
            <asp:FileUpload ID="fileProfile" runat="server" CssClass="file-upload" onchange="previewProfileImage(this)" />

            <div class="row-2">
                <asp:TextBox ID="txtFirstName" runat="server" CssClass="input-box" placeholder="First Name"></asp:TextBox>
                <asp:TextBox ID="txtLastName" runat="server" CssClass="input-box" placeholder="Last Name"></asp:TextBox>
            </div>

            <asp:TextBox ID="txtUsername" runat="server" CssClass="input-box" placeholder="Username"></asp:TextBox>
            <asp:TextBox ID="txtEmail" runat="server" CssClass="input-box" placeholder="Email"></asp:TextBox>
            <asp:TextBox ID="txtPassword" runat="server" CssClass="input-box" TextMode="Password" placeholder="Password"></asp:TextBox>
            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input-box" TextMode="Password" placeholder="Confirm Password"></asp:TextBox>

            <asp:DropDownList ID="ddlUserType" runat="server" CssClass="dropdown-box">
                <asp:ListItem Text="Select User Type" Value=""></asp:ListItem>
                <asp:ListItem Text="Admin" Value="Admin"></asp:ListItem>
                <asp:ListItem Text="Organization" Value="Organization"></asp:ListItem>
                <asp:ListItem Text="Single User" Value="SingleUser"></asp:ListItem>
            </asp:DropDownList>

            <asp:TextBox ID="txtNIC" runat="server" CssClass="input-box" placeholder="NIC Number"></asp:TextBox>
            <asp:TextBox ID="txtMobile" runat="server" CssClass="input-box" placeholder="Mobile Number"></asp:TextBox>

            <div id="mapPreview" class="map-box"></div>

            <div class="map-help">Tap or click on the map to set location manually if automatic location fails.</div>

            <asp:TextBox ID="txtLocation" runat="server" CssClass="input-box" placeholder="Location coordinates will appear here" ReadOnly="true"></asp:TextBox>
            <asp:Label ID="lblLocationStatus" runat="server" CssClass="location-status" Text="Click 'Get Current Location' or select on map."></asp:Label>

            <input type="button" class="btn-location" value="Get Current Location" onclick="getCurrentLocation();" />

            <asp:HiddenField ID="hfLatitude" runat="server" />
            <asp:HiddenField ID="hfLongitude" runat="server" />

            <asp:Button ID="btnSignup" runat="server" Text="Signup" CssClass="btn-signup" OnClick="btnSignup_Click" />

            <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>
        </div>
    </form>
</body>
</html>