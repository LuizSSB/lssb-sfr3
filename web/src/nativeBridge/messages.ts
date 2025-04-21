import { AppErrorCode } from "../models/utils/AppError";

export type BridgePayload = { payloadName: string };

export type CancelBridgePayload = {
  payloadName: "CancelWebBridgePayload";
};

export type ErrorBridgePayload = {
  payloadName: "ErrorWebBridgePayload";
  error: AppErrorCode;
};

export type GetItemRequestBridgePayload = {
  payloadName: "GetItemRequestWebBridgePayload";
  itemId: string;
};

export type GetItemResponseBridgePayload = {
  payloadName: "GetItemResponseWebBridgePayload";
  item?: Item;
};

export type CheckItemNameAvailabilityRequestBridgePayload = {
  payloadName: "CheckItemNameAvailabilityRequestWebBridgePayload";
  itemId?: string;
  itemName: string;
};

export type CheckItemNameAvailabilityResponseBridgePayload = {
  payloadName: "CheckItemNameAvailabilityResponseWebBridgePayload";
  isAvailable: boolean;
};

export type SaveItemRequestBridgePayload = {
  payloadName: "SaveItemRequestWebBridgePayload";
  item: Item;
};

export type SaveItemResponseBridgePayload = {
  payloadName: "SaveItemResponseWebBridgePayload";
};

export type NativeBridgeMessage = {
  messageId: string;
  payloadName: string;
  payload: string;
};

export const NativeBridgeMessageEx = {
  new(messageId: string, payload: BridgePayload): NativeBridgeMessage {
    return {
      messageId,
      payloadName: payload.payloadName,
      payload: JSON.stringify({
        ...payload,
        payloadName: undefined,
      }),
    };
  },
  deserializePayload<TResponse extends BridgePayload>(
    message: NativeBridgeMessage,
  ): TResponse {
    const payload = JSON.parse(message.payload);
    payload.payloadName = message.payloadName;
    return payload;
  },
};
