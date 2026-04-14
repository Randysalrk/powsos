<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="pow.SignUp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>PawSoS - Signup</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 0;
            background: #eeeeee;
            font-family: 'Segoe UI', Arial, sans-serif;
        }

        .page {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding-top: 28px;
            padding-bottom: 30px;
        }

        .wrap {
            width: 100%;
            max-width: 290px;
        }

        .logo {
            text-align: center;
            font-size: 18px;
            font-weight: 400;
            margin-bottom: 26px;
        }

        .logo-paw {
            color: #f0aa2a;
        }

        .logo-sos {
            color: #444;
        }

        .title {
            font-size: 18px;
            font-weight: 400;
            color: #222;
            margin: 0 0 10px 0;
        }

        .upload-box {
            width: 55px;
            height: 55px;
            background: #d9d9d9;
            border-radius: 8px;
            color: #8a8a8a;
            font-size: 8px;
            line-height: 1.2;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 4px;
            margin-bottom: 10px;
            cursor: pointer;
            overflow: hidden;
        }

        .upload-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: none;
        }

        .hidden-file {
            display: none;
        }

        .row {
            display: flex;
            gap: 6px;
            margin-bottom: 8px;
        }

        .input {
            width: 100%;
            height: 28px;
            border: none;
            outline: none;
            background: #d4d4d4;
            border-radius: 4px;
            padding: 0 10px;
            font-size: 11px;
            color: #333;
            margin-bottom: 8px;
        }

        .row .input {
            margin-bottom: 0;
        }

        .input::placeholder {
            color: #8a8a8a;
        }

        .map-box {
            width: 100%;
            height: 120px;
            border-radius: 6px;
            overflow: hidden;
            background: #dcdcdc;
            margin-bottom: 8px;
            border: 1px solid #d0d0d0;
        }

        .map-box iframe {
            width: 100%;
            height: 100%;
            border: 0;
        }

        .map-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #7a7a7a;
            font-size: 11px;
            text-align: center;
            padding: 10px;
        }

        .location-btn {
            width: 100%;
            height: 30px;
            border: none;
            border-radius: 4px;
            background: #cfcfcf;
            color: #333;
            font-size: 11px;
            cursor: pointer;
            margin-bottom: 8px;
        }

        .location-btn:hover {
            background: #c4c4c4;
        }

        .btn {
            width: 100%;
            height: 34px;
            border: none;
            border-radius: 5px;
            background: #efb33f;
            color: #222;
            font-size: 14px;
            cursor: pointer;
            margin-top: 4px;
        }

        .btn:hover {
            background: #e4a52e;
        }

        .status-text {
            font-size: 10px;
            color: #666;
            margin: 0 0 8px 0;
            min-height: 14px;
        }
    </style>

    <script>
        function openPicker() {
            document.getElementById('<%= fileProfile.ClientID %>').click();
        }

        function previewImage(input) {
            var img = document.getElementById('imgPreview');
            var txt = document.getElementById('uploadText');

            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    img.src = e.target.result;
                    img.style.display = 'block';
                    txt.style.display = 'none';
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function getCurrentLocation() {
            var status = document.getElementById('locationStatus');
            var txtLocation = document.getElementById('<%= txtLocation.ClientID %>');
            var txtLat = document.getElementById('<%= txtLatitude.ClientID %>');
            var txtLng = document.getElementById('<%= txtLongitude.ClientID %>');
            var mapFrame = document.getElementById('mapFrame');
            var mapPlaceholder = document.getElementById('mapPlaceholder');

            if (!navigator.geolocation) {
                status.innerHTML = 'Geolocation is not supported by this browser.';
                return;
            }

            status.innerHTML = 'Getting current location...';

            navigator.geolocation.getCurrentPosition(
                function (position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;

                    txtLat.value = lat;
                    txtLng.value = lng;
                    txtLocation.value = lat + ', ' + lng;

                    var mapUrl = 'https://maps.google.com/maps?q=' + lat + ',' + lng + '&z=15&output=embed';
                    mapFrame.src = mapUrl;
                    mapFrame.style.display = 'block';
                    mapPlaceholder.style.display = 'none';

                    status.innerHTML = 'Current location loaded successfully.';
                },
                function (error) {
                    switch (error.code) {
                        case error.PERMISSION_DENIED:
                            status.innerHTML = 'Location access was denied.';
                            break;
                        case error.POSITION_UNAVAILABLE:
                            status.innerHTML = 'Location information is unavailable.';
                            break;
                        case error.TIMEOUT:
                            status.innerHTML = 'The request to get location timed out.';
                            break;
                        default:
                            status.innerHTML = 'An unknown error occurred.';
                            break;
                    }
                }
            );
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page">
            <div class="wrap">

                <div class="logo">
                    <span class="logo-paw">Paw</span><span class="logo-sos">SoS</span>
                </div>

                <h2 class="title">Signup</h2>

                <div class="upload-box" onclick="openPicker()">
                    <span id="uploadText">Upload<br />profile pic<br />here</span>
                    <img id="imgPreview" alt="preview" />
                </div>

                <asp:FileUpload ID="fileProfile" runat="server" CssClass="hidden-file" onchange="previewImage(this)" />

                <div class="row">
                    <asp:TextBox ID="txtFirstName" runat="server" CssClass="input" placeholder="First Name"></asp:TextBox>
                    <asp:TextBox ID="txtLastName" runat="server" CssClass="input" placeholder="Last Name"></asp:TextBox>
                </div>

                <asp:TextBox ID="txtEmail" runat="server" CssClass="input" TextMode="Email" placeholder="Email address"></asp:TextBox>

                <asp:TextBox ID="txtNIC" runat="server" CssClass="input" placeholder="NIC Number"></asp:TextBox>

                <asp:TextBox ID="txtMobile" runat="server" CssClass="input" placeholder="Mobile Number"></asp:TextBox>

                <div class="map-box">
                    <div id="mapPlaceholder" class="map-placeholder">
                        Map preview will appear here
                    </div>
                    <iframe id="mapFrame" style="display:none;"></iframe>
                </div>

                <asp:TextBox ID="txtLocation" runat="server" CssClass="input" placeholder="Location"></asp:TextBox>

                <asp:HiddenField ID="txtLatitude" runat="server" />
                <asp:HiddenField ID="txtLongitude" runat="server" />

                <div id="locationStatus" class="status-text"></div>

                <button type="button" class="location-btn" onclick="getCurrentLocation()">
                    Get Current Location
                </button>

                <asp:Button ID="btnSignup" runat="server" Text="Signup" CssClass="btn" />

            </div>
        </div>
    </form>
</body>
</html>