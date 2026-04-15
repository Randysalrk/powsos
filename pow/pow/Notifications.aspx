<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Mobile.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="pow.Notifications" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css" />

    <style>
        .notify-page {
            width: 100%;
            max-width: 760px;
            margin: 0 auto;
            padding: 20px 16px 40px;
            box-sizing: border-box;
            background: #efefef;
            min-height: 100vh;
        }

        .page-title {
            font-size: 40px;
            color: #d79a18;
            text-align: center;
            margin: 12px 0 24px;
            font-weight: 600;
        }

        .section-title {
            font-size: 24px;
            color: #333;
            margin: 0 0 14px;
            font-weight: 600;
        }

        .empty-box {
            background: #fff;
            padding: 18px;
            border-radius: 10px;
            color: #666;
            border: 1px solid #ddd;
            text-align: center;
            font-size: 15px;
        }

        .notify-card {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 12px;
            padding: 14px;
            margin-bottom: 14px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }

        .notify-row {
            margin-bottom: 8px;
            font-size: 15px;
            color: #333;
            line-height: 1.5;
        }

        .notify-label {
            font-weight: 600;
            color: #444;
        }

        .btn-view {
            width: 100%;
            margin-top: 10px;
            background: #e3a52f;
            border: none;
            border-radius: 8px;
            color: #222;
            padding: 11px 12px;
            font-size: 15px;
            cursor: pointer;
            font-weight: 600;
        }

        .btn-view:hover {
            background: #d5961f;
        }

        .details-box {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 12px;
            padding: 16px;
            margin-top: 20px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }

        .detail-row {
            margin-bottom: 10px;
            font-size: 15px;
            color: #333;
            line-height: 1.6;
            word-break: break-word;
        }

        #map {
            width: 100%;
            height: 360px;
            border-radius: 10px;
            margin-top: 16px;
            border: 1px solid #ccc;
            background: #f8f8f8;
        }

        .distance-box {
            margin-top: 14px;
            padding: 12px;
            border-radius: 8px;
            background: #f8f3e7;
            border: 1px solid #ecd8a1;
            color: #444;
            font-size: 15px;
            font-weight: 600;
            text-align: center;
        }

        @media (max-width: 768px) {
            .notify-page {
                max-width: 420px;
                padding: 16px 12px 30px;
            }

            .page-title {
                font-size: 30px;
            }

            .section-title {
                font-size: 20px;
            }

            #map {
                height: 300px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="FeaturedContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="notify-page">
        <div class="page-title">Notifications</div>

        <div class="section-title">Received Alerts</div>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-box">
            No notifications found.
        </asp:Panel>

        <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
            <ItemTemplate>
                <div class="notify-card">
                    <div class="notify-row">
                        <span class="notify-label">Alert ID:</span>
                        <%# Eval("AlertId") %>
                    </div>

                    <div class="notify-row">
                        <span class="notify-label">Raised By:</span>
                        <%# Eval("RaisedByName") %>
                    </div>

                    <div class="notify-row">
                        <span class="notify-label">Sent Time:</span>
                        <%# Eval("SentAt", "{0:yyyy-MM-dd hh:mm tt}") %>
                    </div>

                    <div class="notify-row">
                        <span class="notify-label">Status:</span>
                        <%# Convert.ToBoolean(Eval("IsSeen")) ? "Seen" : "New" %>
                    </div>

                    <asp:Button ID="btnView" runat="server"
                        Text="View Details"
                        CssClass="btn-view"
                        CommandName="ViewNotification"
                        CommandArgument='<%# Eval("NotificationId") %>' />
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="details-box">
            <div class="section-title" style="margin-top:0;">Notification Details</div>

            <div class="detail-row">
                <strong>Organization:</strong>
                <asp:Label ID="lblOrganizationName" runat="server"></asp:Label>
            </div>

            <div class="detail-row">
                <strong>Organization Location:</strong>
                <asp:Label ID="lblOrganizationLocation" runat="server"></asp:Label>
            </div>

            <div class="detail-row">
                <strong>Raised By:</strong>
                <asp:Label ID="lblRaisedBy" runat="server"></asp:Label>
            </div>

            <div class="detail-row">
                <strong>Raised Alert Location:</strong>
                <asp:Label ID="lblAlertLocation" runat="server"></asp:Label>
            </div>

            <div class="detail-row">
                <strong>Sent Time:</strong>
                <asp:Label ID="lblSentTime" runat="server"></asp:Label>
            </div>

            <asp:HiddenField ID="hfOrgLat" runat="server" />
            <asp:HiddenField ID="hfOrgLng" runat="server" />
            <asp:HiddenField ID="hfAlertLat" runat="server" />
            <asp:HiddenField ID="hfAlertLng" runat="server" />

            <div id="map"></div>

            <div class="distance-box">
                Distance: <asp:Label ID="lblDistance" runat="server"></asp:Label>
            </div>
        </asp:Panel>
    </div>

    <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>

    <script>
        var notifyMap = null;

        function loadNotificationMap() {
            var orgLatField = document.getElementById('<%= hfOrgLat.ClientID %>');
            var orgLngField = document.getElementById('<%= hfOrgLng.ClientID %>');
            var alertLatField = document.getElementById('<%= hfAlertLat.ClientID %>');
            var alertLngField = document.getElementById('<%= hfAlertLng.ClientID %>');

            if (!orgLatField || !orgLngField || !alertLatField || !alertLngField) {
                return;
            }

            var orgLat = parseFloat(orgLatField.value);
            var orgLng = parseFloat(orgLngField.value);
            var alertLat = parseFloat(alertLatField.value);
            var alertLng = parseFloat(alertLngField.value);

            if (isNaN(orgLat) || isNaN(orgLng) || isNaN(alertLat) || isNaN(alertLng)) {
                return;
            }

            var mapContainer = document.getElementById('map');
            if (!mapContainer) {
                return;
            }

            if (notifyMap !== null) {
                notifyMap.remove();
                notifyMap = null;
            }

            notifyMap = L.map('map');

            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; OpenStreetMap contributors'
            }).addTo(notifyMap);

            var orgPoint = [orgLat, orgLng];
            var alertPoint = [alertLat, alertLng];

            var orgMarker = L.marker(orgPoint).addTo(notifyMap)
                .bindPopup('Organization Location');

            var alertMarker = L.marker(alertPoint).addTo(notifyMap)
                .bindPopup('Raised Alert Location');

            var line = L.polyline([orgPoint, alertPoint], {
                color: 'blue',
                weight: 4
            }).addTo(notifyMap);

            notifyMap.fitBounds(line.getBounds(), { padding: [20, 20] });

            setTimeout(function () {
                notifyMap.invalidateSize();
            }, 200);
        }
    </script>
</asp:Content>