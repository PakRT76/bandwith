document.addEventListener('DOMContentLoaded', function () {
    const dashboardLink = document.getElementById('dashboard-link');
    const usersLink = document.getElementById('users-link');
    const reportsLink = document.getElementById('reports-link');

    const dashboardPage = document.getElementById('dashboard');
    const usersPage = document.getElementById('users');
    const reportsPage = document.getElementById('reports');

    const userTableBody = document.querySelector('#user-table tbody');

    const realTimeChart = echarts.init(document.getElementById('real-time-chart'));

    let chartData = {
        categories: [],
        series: [{
            name: 'Download',
            type: 'bar',
            data: []
        }, {
            name: 'Upload',
            type: 'bar',
            data: []
        }]
    };

    function showPage(page) {
        dashboardPage.style.display = 'none';
        usersPage.style.display = 'none';
        reportsPage.style.display = 'none';
        page.style.display = 'block';
    }

    dashboardLink.addEventListener('click', () => showPage(dashboardPage));
    usersLink.addEventListener('click', () => showPage(usersPage));
    reportsLink.addEventListener('click', () => {
        showPage(reportsPage);
        fetchReportsData();
    });

    function fetchReportsData() {
        fetch('/cgi-bin/reports.sh')
            .then(response => response.json())
            .then(data => {
                updateReportsChart(data);
            });
    }

    function updateReportsChart(data) {
        const reportsChart = echarts.init(document.getElementById('reports-chart'));
        const ipAddresses = [...new Set(data.map(d => d.ip_address))];
        const series = ipAddresses.map(ip => {
            return {
                name: ip,
                type: 'line',
                data: data.filter(d => d.ip_address === ip).map(d => [d.timestamp * 1000, d.bytes_in])
            };
        });

        reportsChart.setOption({
            tooltip: {
                trigger: 'axis'
            },
            legend: {
                data: ipAddresses
            },
            xAxis: {
                type: 'time'
            },
            yAxis: {
                type: 'value'
            },
            series: series
        });
    }

    function fetchData() {
        fetch('/cgi-bin/bandwidth.sh')
            .then(response => response.json())
            .then(data => {
                updateChart(data);
                updateUserTable(data);
            });
    }

    function updateChart(data) {
        chartData.categories = data.map(d => d.ip_address);
        chartData.series[0].data = data.map(d => d.bytes_in);
        chartData.series[1].data = data.map(d => d.bytes_out);

        realTimeChart.setOption({
            tooltip: {},
            legend: {
                data: ['Download', 'Upload']
            },
            xAxis: {
                data: chartData.categories
            },
            yAxis: {},
            series: chartData.series
        });
    }

    function updateUserTable(data) {
        userTableBody.innerHTML = '';
        data.forEach(user => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${user.ip_address}</td>
                <td>${user.mac_address}</td>
                <td>${(user.bytes_in / 1024 / 1024).toFixed(2)} MB</td>
                <td>${(user.bytes_out / 1024 / 1024).toFixed(2)} MB</td>
                <td>
                    <button onclick="blockUser('${user.mac_address}')">Block</button>
                    <button onclick="unblockUser('${user.mac_address}')">Unblock</button>
                    <button onclick="limitSpeed('${user.ip_address}')">Limit Speed</button>
                    <button onclick="unlimitSpeed('${user.ip_address}')">Unlimit</button>
                </td>
            `;
            userTableBody.appendChild(row);
        });
    }

    window.blockUser = function (mac) {
        fetch(`/cgi-bin/block.sh?action=block&mac=${mac}`)
            .then(response => response.text())
            .then(message => alert(message));
    };

    window.unblockUser = function (mac) {
        fetch(`/cgi-bin/block.sh?action=unblock&mac=${mac}`)
            .then(response => response.text())
            .then(message => alert(message));
    };

    window.limitSpeed = function (ip) {
        const download = prompt('Enter download speed in Mbps:');
        const upload = prompt('Enter upload speed in Mbps:');
        if (download && upload) {
            fetch(`/cgi-bin/limit.sh?ip=${ip}&download=${download}&upload=${upload}`)
                .then(response => response.text())
                .then(message => alert(message));
        }
    };

    window.unlimitSpeed = function (ip) {
        fetch(`/cgi-bin/unlimit.sh?ip=${ip}`)
            .then(response => response.text())
            .then(message => alert(message));
    };

    fetchData();
    setInterval(fetchData, 5000);
});
