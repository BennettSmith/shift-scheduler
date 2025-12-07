import {setGlobalOptions} from "firebase-functions";
import {healthCheck} from "./interface/http/healthCheck";

// Global options for all functions in this project.
setGlobalOptions({maxInstances: 10});

// HTTP functions
export {healthCheck};
