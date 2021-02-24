// This is a sample config file for the following scenario
// You have the catalog running locally on your dev machine on port 5000
// The Insights UI is running on CI dev cluster
module.exports = {
    routes: {
        '/api/catalog-inventory': { host: 'http://localhost:3000' },
        '/api/catalog': { host: 'http://localhost:5000' },
        '/insights': { host: 'PORTAL_BACKEND_MARKER' }
    }
};
