import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import { iocContainer, loadIoCContainer } from "./ioc";
import { NativeBridge } from "./nativeBridge";

loadIoCContainer();

iocContainer.get(NativeBridge).setUp();

const container = document.getElementById("root");
const root = createRoot(container!);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
