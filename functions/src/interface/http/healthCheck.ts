import {onRequest} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {healthCheckUseCase} from "../../application";

// Thin HTTP handler that delegates to the healthCheck use case.
export const healthCheck = onRequest((req, res) => {
  logger.info("Health check requested");
  const result = healthCheckUseCase();
  res.status(200).json(result);
});


