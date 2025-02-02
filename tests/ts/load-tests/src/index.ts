import http from "k6/http";
import type { Options } from "k6/options";

export const options: Options = {
    discardResponseBodies: true,
    insecureSkipTLSVerify: true,
    vus: 100,
    duration: "2.5m",
    thresholds: {
        http_req_duration: ["p(99)<3000"],
    },
};

const BASE_URL = __ENV.TEST_BASE_URL;

export default function () {
    http.get(`${BASE_URL}/users`);
}
