import { injectable } from "inversify";
import { AppErrorCode } from "../models/utils/AppError";
import {
  BridgePayload,
  ErrorBridgePayload,
  NativeBridgeMessage,
  NativeBridgeMessageEx,
} from "./messages";

@injectable()
export class NativeBridge {
  private pendingHandlers: Map<string, (message: NativeBridgeMessage) => void> =
    new Map();

  setUp = () => {
    if ((window as any).webBridge) {
      return;
    }

    (window as any).webBridge = (message: string) => {
      console.log("native message", message);
      const deserialized: NativeBridgeMessage = JSON.parse(message);
      const handlerForMessage = this.pendingHandlers.get(
        deserialized.messageId,
      );
      handlerForMessage?.(deserialized);
    };
  };

  send = <TRequest extends BridgePayload, TResponse extends BridgePayload>(
    payload: TRequest,
    successHandler: (response: TResponse) => Promise<boolean>,
    failHandler: (response: ErrorBridgePayload) => Promise<boolean>,
  ) => {
    const bridge = (window as any).webkit?.messageHandlers?.webBridge;
    if (!bridge) {
      failHandler({
        payloadName: "ErrorWebBridgePayload",
        error: AppErrorCode.WEB_BRIDGE_UNAVAILABLE,
      });
    }

    const message = NativeBridgeMessageEx.new(
      new Date().getTime().toString(),
      payload,
    );

    this.pendingHandlers.set(message.messageId, async (responseMessage) => {
      const responsePayload: TResponse | ErrorBridgePayload =
        NativeBridgeMessageEx.deserializePayload(responseMessage);
      if (responsePayload.payloadName === "ErrorBridgePayload") {
        if (await failHandler(responsePayload as any)) {
          this.pendingHandlers.delete(message.messageId);
        }
      } else if (await successHandler(responsePayload as any)) {
        this.pendingHandlers.delete(message.messageId);
      }
    });

    bridge.postMessage(JSON.stringify(message));
  };
}
