<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Mobile.Master"
    AutoEventWireup="true" CodeBehind="Raisealert.aspx.cs" Inherits="pow.Raisealert" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />

    <style>
        .alert-wrapper {
            width: 360px;
            margin: 0 auto;
            padding: 20px 15px;
            text-align: center;
            background: #efefef;
            min-height: 100vh;
            box-sizing: border-box;
        }

        .app-title {
            font-size: 34px;
            color: #d79a18;
            margin: 15px 0 20px;
            font-weight: 500;
        }

        #map {
            width: 100%;
            height: 260px;
            border-radius: 4px;
            margin-bottom: 18px;
            border: 1px solid #ccc;
        }

        .txt-location {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d8d8d8;
            border-radius: 6px;
            font-size: 14px;
            margin-bottom: 16px;
            box-sizing: border-box;
        }

        .btn-send {
            width: 100%;
            background: #e3a52f;
            color: #333;
            border: none;
            border-radius: 7px;
            padding: 12px;
            font-size: 16px;
            cursor: pointer;
            font-weight: 500;
        }

        .btn-send:hover {
            background: #d99718;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="alert-wrapper">
        <div class="app-title">PawSoS</div>

        <div id="map"></div>

        <asp:TextBox ID="txtLocation" runat="server" CssClass="txt-location"
            placeholder="Selected location" ReadOnly="true"></asp:TextBox>

        <asp:HiddenField ID="hfLatitude" runat="server" />
        <asp:HiddenField ID="hfLongitude" runat="server" />

        <asp:Button ID="btnSendNotification" runat="server" Text="Send Notification"
            CssClass="btn-send" OnClick="btnSendNotification_Click" />
    </div>

    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>

    <script>
        var defaultLat = 7.2906;   // Sri Lanka area fallback
        var defaultLng = 80.6337;

        var map = L.map('map').setView([defaultLat, defaultLng], 8);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(map);

        var marker = L.marker([defaultLat, defaultLng], { draggable: true }).addTo(map);

        function updateLocationFields(lat, lng) {
            document.getElementById('<%= hfLatitude.ClientID %>').value = lat;
            document.getElementById('<%= hfLongitude.ClientID %>').value = lng;
            document.getElementById('<%= txtLocation.ClientID %>').value = lat.toFixed(6) + ', ' + lng.toFixed(6);
        }

        // Initial values
        updateLocationFields(defaultLat, defaultLng);

        // Get current location
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                function (position) {
                    var lat = position.coords.latitude;
                    var lng = position.coords.longitude;

                    map.setView([lat, lng], 15);
                    marker.setLatLng([lat, lng]);
                    updateLocationFields(lat, lng);
                },
                function (error) {
                    console.log("Location access denied or failed.");
                }
            );
        }

        // Drag marker
        marker.on('dragend', function () {
            var pos = marker.getLatLng();
            updateLocationFields(pos.lat, pos.lng);
        });

        // Click map to move marker
        map.on('click', function (e) {
            marker.setLatLng(e.latlng);
            updateLocationFields(e.latlng.lat, e.latlng.lng);
        });
    </script>
</asp:Content>