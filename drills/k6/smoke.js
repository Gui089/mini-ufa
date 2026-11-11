import http from 'k6/http';
import { check } from 'k6';

const TARGET = __ENV.TARGET || 'http://echo.sandbox.svc.cluster.local';

export const options = {
  scenarios: {
    steady: { executor: 'constant-arrival-rate', rate: 200, timeUnit: '1s', duration: __ENV.DURATION || '5m', preAllocatedVUs: 50 },
  },
  thresholds: { http_req_failed: ['rate<0.01'], http_req_duration: ['p(95)<200'] },
};

export default function () {
  const res = http.get(TARGET);
  check(res, { 'status 200': (r) => r.status === 200 });
}
