// Application layer (use cases).
// Define use case interfaces and simple example implementations here.

import {domainPlaceholder} from "../domain";

export interface HealthCheckResponse {
  status: "ok";
}

export function healthCheckUseCase(): HealthCheckResponse {
  if (!domainPlaceholder.ok) {
    // In real code, you'd throw a domain error here.
    throw new Error("Domain not OK");
  }
  return {status: "ok"};
}


