import { inject } from "inversify";
import { AppErrorError } from "../models/utils/AppError";
import { NativeBridge } from "../nativeBridge";
import {
  CheckItemNameAvailabilityRequestBridgePayload,
  CheckItemNameAvailabilityResponseBridgePayload,
  GetItemRequestBridgePayload,
  GetItemResponseBridgePayload,
  SaveItemRequestBridgePayload,
  SaveItemResponseBridgePayload,
} from "../nativeBridge/messages";

export class ItemDataSource {
  constructor(
    @inject(NativeBridge)
    public readonly nativeBridge: NativeBridge,
  ) {}

  getItem = async (id: string): Promise<Item | undefined> => {
    const item = await new Promise<Item | undefined>((res, rej) => {
      const request: GetItemRequestBridgePayload = {
        payloadName: "GetItemRequestWebBridgePayload",
        itemId: id,
      };
      this.nativeBridge.send(
        request,
        async (response: GetItemResponseBridgePayload) => {
          res(response.item);
          return true;
        },
        async (response) => {
          rej(new AppErrorError(response.error));
          return true;
        },
      );
    });
    return item;
  };

  checkNameAvailability = async (
    name: string,
    existingItemId?: string,
  ): Promise<{ isAvailable: boolean; name: string }> => {
    const isAvailable = await new Promise<boolean>((res, rej) => {
      const request: CheckItemNameAvailabilityRequestBridgePayload = {
        payloadName: "CheckItemNameAvailabilityRequestWebBridgePayload",
        itemId: existingItemId,
        itemName: name,
      };
      this.nativeBridge.send(
        request,
        async (response: CheckItemNameAvailabilityResponseBridgePayload) => {
          res(response.isAvailable);
          return true;
        },
        async (response) => {
          rej(new AppErrorError(response.error));
          return true;
        },
      );
    });
    return { isAvailable, name };
  };

  save = async (item: Omit<Item, "id"> & { id?: string }) => {
    await new Promise((res, rej) => {
      const request: SaveItemRequestBridgePayload = {
        payloadName: "SaveItemRequestWebBridgePayload",
        item: {
          ...item,
          id: item.id ?? new Date().getTime().toString(),
        },
      };
      this.nativeBridge.send(
        request,
        async (response: SaveItemResponseBridgePayload) => {
          res(undefined);
          return true;
        },
        async (response) => {
          rej(new AppErrorError(response.error));
          return true;
        },
      );
    });
  };
}
