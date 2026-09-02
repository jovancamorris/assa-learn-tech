import ballerina/http;
import ballerina/time;

// Listener HTTP berjalan pada port 9090
service /hello on new http:Listener(9090) {

    // Resource method GET yang menerima path parameter /{name}
    resource function get [string name]() returns json {
        // Ambil waktu server saat ini
        string currentTime = time:utcToString(time:utcNow());

        // Mengembalikan format response JSON terstruktur
        return {
            "status": "SUCCESS",
            "message": string `Halo, ${name}! Selamat datang di Antigravity IDE WSO2 Integration.`,
            "ide": "Antigravity IDE (AI-First)",
            "server_time": currentTime
        };
    }
}
