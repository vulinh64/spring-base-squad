import module java.net.http;

import java.net.http.HttpResponse.BodyHandlers;

static final int MAX_ATTEMPTS = 10;
static final long RETRY_DELAY_MS = 1000L;
static final Duration TIMEOUT = Duration.ofSeconds(2);

static final HttpClient HTTP_CLIENT = HttpClient.newBuilder().connectTimeout(TIMEOUT).build();

void main(String[] args) throws InterruptedException {
    if (args.length != 1) {
        IO.println("Usage: java HealthCheck.java <health-check-url>");
        System.exit(2);
    }

    var request = HttpRequest.newBuilder(URI.create(args[0])).timeout(TIMEOUT).GET().build();

    for (var attempt = 0; attempt < MAX_ATTEMPTS; attempt++) {
        if (executeHealthCheck(HTTP_CLIENT, request, attempt)) {
            HTTP_CLIENT.close();
            return;
        }

        if (attempt < MAX_ATTEMPTS - 1) {
            Thread.sleep(RETRY_DELAY_MS);
        }
    }

    IO.println("The service did not become healthy after %s attempts.".formatted(MAX_ATTEMPTS));
    HTTP_CLIENT.close();
    System.exit(1);
}

boolean executeHealthCheck(HttpClient client, HttpRequest request, int attempt)
        throws InterruptedException {
    try {
        var response = client.send(request, BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            IO.println("The service is up!");
            return true;
        }

        IO.println(
                "Health check attempt %s/%s returned HTTP %s."
                        .formatted(attempt + 1, MAX_ATTEMPTS, response.statusCode()));
    } catch (IOException _) {
        IO.println(
                "Health check attempt %s/%s could not connect.".formatted(attempt + 1, MAX_ATTEMPTS));
    }

    return false;
}
