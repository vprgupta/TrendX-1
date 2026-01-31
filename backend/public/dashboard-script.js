// Dashboard JavaScript - Enhanced with Socket.IO and Chart.js
class TrendXDashboard {
    constructor() {
        this.apiBaseUrl = 'http://localhost:3000/api';
        this.socket = null;
        this.currentPage = 'dashboard';
        this.trendChart = null;
        this.platformChart = null;
        this.token = localStorage.getItem('trendx_token'); // Assuming token is stored here

        this.init();
    }

    init() {
        try {
            if (typeof io !== 'undefined') {
                this.setupSocket();
            } else {
                console.warn('Socket.IO is not loaded. Real-time updates will be disabled.');
            }
        } catch (e) {
            console.error('Error setting up socket:', e);
        }

        try {
            this.setupEventListeners();
        } catch (e) {
            console.error('Error setting up event listeners:', e);
        }

        try {
            this.setupTheme();
            this.setupSidebar();
        } catch (e) {
            console.error('Error setting up UI:', e);
        }

        this.loadDashboardData();

        // Check authentication
        if (!this.token) {
            console.warn('No auth token found');
        }
    }

    getHeaders() {
        const headers = {
            'Content-Type': 'application/json'
        };
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        return headers;
    }

    setupSocket() {
        this.socket = io('http://localhost:3000');

        this.socket.on('connect', () => {
            console.log('Connected to Socket.IO server');
        });

        this.socket.on('trendCreated', (trend) => {
            this.showNotification(`New trend created: ${trend.title}`, 'success');
            if (this.currentPage === 'dashboard' || this.currentPage === 'trends') {
                this.loadDashboardData();
                this.loadTrendsData();
            }
        });

        this.socket.on('trendUpdated', (trend) => {
            this.showNotification(`Trend updated: ${trend.title}`, 'info');
            if (this.currentPage === 'trends') {
                this.loadTrendsData();
            }
        });

        this.socket.on('trendDeleted', (trendId) => {
            this.showNotification('Trend deleted', 'warning');
            if (this.currentPage === 'trends') {
                this.loadTrendsData();
            }
        });
    }

    setupEventListeners() {
        // ... (Existing event listeners) ...
        const themeToggle = document.getElementById('themeToggle');
        if (themeToggle) themeToggle.addEventListener('click', () => this.toggleTheme());

        const sidebarToggle = document.getElementById('sidebarToggle');
        if (sidebarToggle) sidebarToggle.addEventListener('click', () => this.toggleSidebar());

        const navItems = document.querySelectorAll('.nav-item[data-page]');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const page = item.getAttribute('data-page');
                this.navigateToPage(page);
            });
        });

        // Modal Forms
        const trendForm = document.getElementById('trendForm');
        if (trendForm) {
            trendForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.saveTrend();
            });
        }

        const userForm = document.getElementById('userForm');
        if (userForm) {
            userForm.addEventListener('submit', (e) => {
                e.preventDefault();
                this.saveUser();
            });
        }

        // Refresh buttons
        document.getElementById('refreshTrendsBtn')?.addEventListener('click', () => this.loadTrendsData());
        document.getElementById('refreshUsersBtn')?.addEventListener('click', () => this.loadUsersData());
        document.getElementById('addUserBtn')?.addEventListener('click', () => this.openUserModal());
        document.getElementById('saveSettingsBtn')?.addEventListener('click', () => this.saveSettings());
        document.getElementById('refreshDocsBtn')?.addEventListener('click', () => this.loadApiDocs());
        document.getElementById('refreshNewsBtn')?.addEventListener('click', () => this.loadNews());

        document.querySelectorAll('.news-tab').forEach(tab => {
            tab.addEventListener('click', (e) => {
                const category = e.target.dataset.category;
                this.loadNews(category);
            });
        });
    }

    // ... (Theme and Sidebar methods remain same) ...
    setupTheme() {
        const savedTheme = localStorage.getItem('trendx-theme') || 'light';
        this.setTheme(savedTheme);
    }

    toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        this.setTheme(newTheme);
    }

    setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('trendx-theme', theme);
        const themeIcon = document.getElementById('themeIcon');
        if (themeIcon) themeIcon.className = theme === 'light' ? 'fas fa-moon' : 'fas fa-sun';
    }

    setupSidebar() { /* ... same as before ... */ }
    toggleSidebar() { /* ... same as before ... */ }
    collapseSidebar() { /* ... same as before ... */ }
    expandSidebar() { /* ... same as before ... */ }

    navigateToPage(page) {
        // Update active nav item
        document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
        const activeItem = document.querySelector(`.nav-item[data-page="${page}"]`);
        if (activeItem) activeItem.classList.add('active');

        // Show/hide content
        document.querySelectorAll('.page-content').forEach(content => content.style.display = 'none');
        const targetPage = document.getElementById(page + 'Page');
        if (targetPage) targetPage.style.display = 'block';

        this.currentPage = page;

        // Load data
        switch (page) {
            case 'dashboard': this.loadDashboardData(); break;
            case 'trends': this.loadTrendsData(); break;
            case 'users': this.loadUsersData(); break;
            case 'analytics': this.loadAnalyticsData(); break;
            case 'settings': this.loadSettings(); break;
            case 'api-docs': this.loadApiDocs(); break;
            case 'news': this.loadNews(); break;
        }
    }

    async loadDashboardData() {
        try {
            const [usersRes, trendsRes] = await Promise.all([
                fetch(`${this.apiBaseUrl}/auth/stats`, { headers: this.getHeaders() }),
                fetch(`${this.apiBaseUrl}/trends`, { headers: this.getHeaders() })
            ]);

            if (usersRes.ok) {
                const stats = await usersRes.json();
                document.getElementById('totalUsers').textContent = stats.total?.toLocaleString() || '0';
            }

            if (trendsRes.ok) {
                const trendsData = await trendsRes.json();
                const count = trendsData.pagination ? trendsData.pagination.total : trendsData.trends.length;
                document.getElementById('totalTrends').textContent = count.toLocaleString();
            }
        } catch (error) {
            console.error('Error loading dashboard data:', error);
        }
    }

    // --- Trends Management ---

    async loadTrendsData() {
        const tbody = document.getElementById('trendsTableBody');
        if (!tbody) return;
        tbody.innerHTML = '<tr><td colspan="7" class="loading-cell"><i class="fas fa-spinner fa-spin"></i> Loading...</td></tr>';

        try {
            const response = await fetch(`${this.apiBaseUrl}/trends`, { headers: this.getHeaders() });
            if (response.ok) {
                const data = await response.json();
                this.renderTrendsTable(data.trends || []);
            }
        } catch (error) {
            tbody.innerHTML = '<tr><td colspan="7" class="loading-cell">Error loading trends</td></tr>';
        }
    }

    renderTrendsTable(trends) {
        const tbody = document.getElementById('trendsTableBody');
        if (!tbody) return;

        if (trends.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="loading-cell">No trends found</td></tr>';
            return;
        }

        tbody.innerHTML = trends.map(trend => `
            <tr>
                <td>
                    <div style="font-weight: 500;">${this.escapeHtml(trend.title)}</div>
                    <div style="font-size: 0.875rem; color: var(--text-secondary);">${this.escapeHtml(trend.description || '')}</div>
                </td>
                <td><span class="platform-badge platform-${(trend.platform || 'news').toLowerCase()}">${trend.platform || 'News'}</span></td>
                <td>${(trend.metrics?.views || 0).toLocaleString()}</td>
                <td>${this.getSentimentBadge(trend.sentiment)}</td>
                <td>${new Date(trend.createdAt).toLocaleDateString()}</td>
                <td>${this.getStatusBadge(trend.status)}</td>
                <td>
                    <button class="action-btn-small action-btn-view" onclick="dashboard.editTrend('${trend._id}')"><i class="fas fa-edit"></i></button>
                    <button class="action-btn-small action-btn-delete" onclick="dashboard.deleteTrend('${trend._id}')"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');
    }

    async editTrend(id) {
        try {
            const response = await fetch(`${this.apiBaseUrl}/trends/${id}`, { headers: this.getHeaders() });
            if (response.ok) {
                const trend = await response.json();
                document.getElementById('trendId').value = trend._id;
                document.getElementById('trendTitle').value = trend.title;
                document.getElementById('trendDescription').value = trend.description || '';
                document.getElementById('trendPlatform').value = trend.platform || 'twitter';
                document.getElementById('trendStatus').value = trend.status || 'active';

                document.getElementById('trendModalTitle').textContent = 'Edit Trend';
                document.getElementById('trendModal').style.display = 'flex';
            }
        } catch (error) {
            console.error('Error fetching trend details:', error);
        }
    }

    async saveTrend() {
        const id = document.getElementById('trendId').value;
        const data = {
            title: document.getElementById('trendTitle').value,
            description: document.getElementById('trendDescription').value,
            platform: document.getElementById('trendPlatform').value,
            status: document.getElementById('trendStatus').value
        };

        try {
            const url = id ? `${this.apiBaseUrl}/trends/${id}` : `${this.apiBaseUrl}/trends`;
            const method = id ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: this.getHeaders(),
                body: JSON.stringify(data)
            });

            if (response.ok) {
                this.closeTrendModal();
                this.loadTrendsData();
                this.showNotification('Trend saved successfully', 'success');
            } else {
                this.showNotification('Failed to save trend', 'error');
            }
        } catch (error) {
            console.error('Error saving trend:', error);
            this.showNotification('Error saving trend', 'error');
        }
    }

    async deleteTrend(id) {
        if (!confirm('Are you sure you want to delete this trend?')) return;

        try {
            const response = await fetch(`${this.apiBaseUrl}/trends/${id}`, {
                method: 'DELETE',
                headers: this.getHeaders()
            });

            if (response.ok) {
                this.loadTrendsData();
                this.showNotification('Trend deleted successfully', 'success');
            }
        } catch (error) {
            console.error('Error deleting trend:', error);
        }
    }

    closeTrendModal() {
        document.getElementById('trendModal').style.display = 'none';
        document.getElementById('trendForm').reset();
        document.getElementById('trendId').value = '';
    }

    // --- User Management ---

    async loadUsersData() {
        const tbody = document.getElementById('usersTableBody');
        if (!tbody) return;
        tbody.innerHTML = '<tr><td colspan="6" class="loading-cell"><i class="fas fa-spinner fa-spin"></i> Loading...</td></tr>';

        try {
            const response = await fetch(`${this.apiBaseUrl}/auth/users`, { headers: this.getHeaders() });
            if (response.ok) {
                const data = await response.json();
                this.renderUsersTable(data.users || []);
            }
        } catch (error) {
            tbody.innerHTML = '<tr><td colspan="6" class="loading-cell">Error loading users</td></tr>';
        }
    }

    renderUsersTable(users) {
        const tbody = document.getElementById('usersTableBody');
        if (!tbody) return;

        tbody.innerHTML = users.map(user => `
            <tr>
                <td>
                    <div style="font-weight: 500;">${this.escapeHtml(user.name)}</div>
                    <div style="font-size: 0.875rem; color: var(--text-secondary);">${this.escapeHtml(user.email)}</div>
                </td>
                <td><span class="badge badge-secondary">${user.role}</span></td>
                <td>${this.getStatusBadge(user.status || 'active')}</td>
                <td>${new Date(user.createdAt).toLocaleDateString()}</td>
                <td>
                    <button class="action-btn-small action-btn-view" onclick="dashboard.editUser('${user._id}', '${user.name}', '${user.email}', '${user.role}')"><i class="fas fa-edit"></i></button>
                    <button class="action-btn-small action-btn-delete" onclick="dashboard.deleteUser('${user._id}')"><i class="fas fa-trash"></i></button>
                </td>
            </tr>
        `).join('');
    }

    openUserModal() {
        document.getElementById('userModalTitle').textContent = 'Add User';
        document.getElementById('userForm').reset();
        document.getElementById('userId').value = '';
        document.getElementById('passwordGroup').style.display = 'block';
        document.getElementById('userModal').style.display = 'flex';
    }

    editUser(id, name, email, role) {
        document.getElementById('userModalTitle').textContent = 'Edit User';
        document.getElementById('userId').value = id;
        document.getElementById('userName').value = name;
        document.getElementById('userEmail').value = email;
        document.getElementById('userRole').value = role;
        document.getElementById('passwordGroup').style.display = 'none'; // Hide password for edit
        document.getElementById('userModal').style.display = 'flex';
    }

    async saveUser() {
        const id = document.getElementById('userId').value;
        const data = {
            name: document.getElementById('userName').value,
            email: document.getElementById('userEmail').value,
            role: document.getElementById('userRole').value
        };

        if (!id) {
            data.password = document.getElementById('userPassword').value;
        }

        try {
            const url = id ? `${this.apiBaseUrl}/auth/users/${id}` : `${this.apiBaseUrl}/auth/users`;
            const method = id ? 'PUT' : 'POST';

            const response = await fetch(url, {
                method: method,
                headers: this.getHeaders(),
                body: JSON.stringify(data)
            });

            if (response.ok) {
                this.closeUserModal();
                this.loadUsersData();
                this.showNotification('User saved successfully', 'success');
            } else {
                const err = await response.json();
                this.showNotification(err.error || 'Failed to save user', 'error');
            }
        } catch (error) {
            console.error('Error saving user:', error);
            this.showNotification('Error saving user', 'error');
        }
    }

    async deleteUser(id) {
        if (!confirm('Are you sure you want to delete this user?')) return;

        try {
            const response = await fetch(`${this.apiBaseUrl}/auth/users/${id}`, {
                method: 'DELETE',
                headers: this.getHeaders()
            });

            if (response.ok) {
                this.loadUsersData();
                this.showNotification('User deleted successfully', 'success');
            }
        } catch (error) {
            console.error('Error deleting user:', error);
        }
    }

    closeUserModal() {
        document.getElementById('userModal').style.display = 'none';
        document.getElementById('userForm').reset();
    }

    // --- Settings Management ---

    loadSettings() {
        const settings = JSON.parse(localStorage.getItem('trendx_settings') || '{}');
        if (document.getElementById('siteName')) document.getElementById('siteName').value = settings.siteName || 'TrendX';
        if (document.getElementById('maintenanceMode')) document.getElementById('maintenanceMode').value = settings.maintenanceMode || 'false';
        if (document.getElementById('sessionTimeout')) document.getElementById('sessionTimeout').value = settings.sessionTimeout || '60';
        if (document.getElementById('maxLoginAttempts')) document.getElementById('maxLoginAttempts').value = settings.maxLoginAttempts || '5';
        if (document.getElementById('emailAlerts')) document.getElementById('emailAlerts').checked = settings.emailAlerts !== false;
        if (document.getElementById('systemNotifications')) document.getElementById('systemNotifications').checked = settings.systemNotifications !== false;
    }

    saveSettings() {
        const settings = {
            siteName: document.getElementById('siteName').value,
            maintenanceMode: document.getElementById('maintenanceMode').value,
            sessionTimeout: document.getElementById('sessionTimeout').value,
            maxLoginAttempts: document.getElementById('maxLoginAttempts').value,
            emailAlerts: document.getElementById('emailAlerts').checked,
            systemNotifications: document.getElementById('systemNotifications').checked
        };
        localStorage.setItem('trendx_settings', JSON.stringify(settings));
        this.showNotification('Settings saved successfully', 'success');
    }

    // --- API Documentation ---

    async loadApiDocs() {
        const container = document.getElementById('apiDocsContainer');
        if (!container) return;
        container.innerHTML = '<div class="loading-cell"><i class="fas fa-spinner fa-spin"></i> Loading documentation...</div>';

        try {
            const response = await fetch(`${this.apiBaseUrl}/docs`);
            if (response.ok) {
                const docs = await response.json();
                this.renderApiDocs(docs);
            } else {
                container.innerHTML = '<div class="error-message">Failed to load API documentation</div>';
            }
        } catch (error) {
            console.error('Error loading API docs:', error);
            container.innerHTML = '<div class="error-message">Error loading API documentation</div>';
        }
    }

    renderApiDocs(docs) {
        const container = document.getElementById('apiDocsContainer');
        if (!container) return;

        let html = `
            <div class="api-info">
                <h3>${docs.title} <span class="badge badge-secondary">v${docs.version}</span></h3>
                <p>Base URL: <code>${this.apiBaseUrl}</code></p>
            </div>
            <div class="api-endpoints">
        `;

        for (const [group, endpoints] of Object.entries(docs.endpoints)) {
            html += `
                <div class="endpoint-group">
                    <h4 style="text-transform: capitalize;">${group}</h4>
                    <div class="endpoint-list">
            `;

            for (const [path, desc] of Object.entries(endpoints)) {
                const [method, url] = path.split(' ');
                const methodClass = `method-${method.toLowerCase()}`;
                html += `
                    <div class="endpoint-item">
                        <span class="endpoint-method ${methodClass}">${method}</span>
                        <span class="endpoint-url">${url}</span>
                        <span class="endpoint-desc">${desc}</span>
                    </div>
                `;
            }

            html += `
                    </div>
                </div>
            `;
        }

        html += '</div>';
        container.innerHTML = html;
    }

    // --- News Integration ---

    async loadNews(category = 'world') {
        const grid = document.getElementById('newsGrid');
        if (!grid) return;
        grid.innerHTML = '<div class="loading-cell"><i class="fas fa-spinner fa-spin"></i> Loading news...</div>';

        // Update active tab
        document.querySelectorAll('.news-tab').forEach(tab => {
            tab.classList.toggle('active', tab.dataset.category === category);
        });

        try {
            const response = await fetch(`${this.apiBaseUrl}/news/${category}`);
            if (response.ok) {
                const data = await response.json();
                this.renderNews(data.data);
            } else {
                grid.innerHTML = '<div class="error-message">Failed to load news</div>';
            }
        } catch (error) {
            console.error('Error loading news:', error);
            grid.innerHTML = '<div class="error-message">Error loading news</div>';
        }
    }

    renderNews(newsItems) {
        const grid = document.getElementById('newsGrid');
        if (!grid) return;

        if (newsItems.length === 0) {
            grid.innerHTML = '<div class="no-data">No news found</div>';
            return;
        }

        grid.innerHTML = newsItems.map(item => `
            <div class="news-card">
                <div class="news-image">
                    <img src="${item.imageUrl || 'https://via.placeholder.com/300x200?text=News'}" alt="News Image" onerror="this.src='https://via.placeholder.com/300x200?text=News'">
                </div>
                <div class="news-content">
                    <div class="news-meta">
                        <span class="news-source">${this.escapeHtml(item.source)}</span>
                        <span class="news-date">${new Date(item.pubDate).toLocaleDateString()}</span>
                    </div>
                    <h3 class="news-title"><a href="${item.link}" target="_blank">${this.escapeHtml(item.title)}</a></h3>
                    <p class="news-snippet">${this.escapeHtml(item.contentSnippet || item.content).substring(0, 100)}...</p>
                    <a href="${item.link}" target="_blank" class="news-link">Read more <i class="fas fa-external-link-alt"></i></a>
                </div>
            </div>
        `).join('');
    }

    // --- Analytics & Charts ---

    async loadAnalyticsData() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/analytics/chart`, { headers: this.getHeaders() });
            if (response.ok) {
                const data = await response.json();
                this.createTrendChart(data);
            }
        } catch (error) {
            console.error('Error loading analytics:', error);
        }
    }

    createTrendChart(data) {
        const ctx = document.getElementById('trendChart')?.getContext('2d');
        if (!ctx) return;

        if (this.trendChart) {
            this.trendChart.destroy();
        }

        if (typeof Chart !== 'undefined') {
            this.trendChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.map(d => d.date),
                    datasets: [{
                        label: 'Trend Views',
                        data: data.map(d => d.views),
                        borderColor: '#3B82F6',
                        tension: 0.4,
                        fill: true,
                        backgroundColor: 'rgba(59, 130, 246, 0.1)'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: { beginAtZero: true }
                    }
                }
            });
        } else {
            console.warn('Chart.js is not loaded. Charts will be disabled.');
        }
    }

    // --- Helpers ---

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    getSentimentBadge(sentiment) {
        const colors = { positive: 'success', negative: 'error', neutral: 'secondary' };
        const color = colors[sentiment] || 'secondary';
        return `<span class="badge" style="background-color: var(--${color}-color); color: white; padding: 0.25rem 0.5rem; border-radius: 0.25rem; font-size: 0.75rem;">${sentiment}</span>`;
    }

    getStatusBadge(status) {
        const colors = { active: 'success', inactive: 'secondary', pending: 'warning' };
        const color = colors[status] || 'secondary';
        return `<span class="badge" style="background-color: var(--${color}-color); color: white; padding: 0.25rem 0.5rem; border-radius: 0.25rem; font-size: 0.75rem;">${status}</span>`;
    }

    showNotification(message, type = 'info') {
        // Simple alert for now, can be enhanced to toast
        console.log(`[${type.toUpperCase()}] ${message}`);
        // Implement toast UI here if needed
    }
}

// Initialize Dashboard
const dashboard = new TrendXDashboard();

// Global functions for HTML event handlers
function closeTrendModal() { dashboard.closeTrendModal(); }
function closeUserModal() { dashboard.closeUserModal(); }