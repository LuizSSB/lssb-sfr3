import { createSlice } from "@reduxjs/toolkit";
import {
  all,
  call,
  put,
  select,
  takeLatest,
  takeLeading,
} from "redux-saga/effects";
import { ItemDataSource } from "../../datasources/ItemDataSource";
import { iocContainer } from "../../ioc";
import { ActionStatus } from "../../models/utils/ActionStatus";
import { AppErrorCode, AppErrorEx } from "../../models/utils/AppError";
import { NativeBridge } from "../../nativeBridge";
import { CancelBridgePayload } from "../../nativeBridge/messages";

type ItemFormState = {
  id?: string;
  getItemStatus: ActionStatus<Item | undefined>;

  name: string;
  nameCheckStatus: ActionStatus<{ name: string; isAvailable: boolean }>;

  saveStatus: ActionStatus;
};

const initialState: ItemFormState = {
  getItemStatus: { type: "none" },
  name: "",
  nameCheckStatus: { type: "none" },
  saveStatus: { type: "none" },
};

export const itemFormSlice = createSlice({
  name: "itemForm",
  initialState,
  reducers: {
    getItem(state, action: { payload: string }) {},
    getItemStatusResponse(
      state,
      action: { payload: ItemFormState["getItemStatus"] },
    ) {
      state.getItemStatus = action.payload;
      switch (action.payload.type) {
        case "success":
          state.id = action.payload.result?.id;
          state.name = action.payload.result?.name ?? "";
      }
    },
    name(state, action: { payload: string }) {
      state.name = action.payload;
    },
    nameCheckStatusResponse(
      state,
      action: { payload: ItemFormState["nameCheckStatus"] },
    ) {
      state.nameCheckStatus = action.payload;
    },
    save(state) {},
    saveStatusResponse(
      state,
      action: { payload: ItemFormState["saveStatus"] },
    ) {
      state.saveStatus = action.payload;
    },
  },
});

function* getItem(
  action: ReturnType<typeof itemFormSlice.actions.getItem>,
): any {
  try {
    yield put(itemFormSlice.actions.getItemStatusResponse({ type: "running" }));

    const result = yield call(
      iocContainer.get(ItemDataSource).getItem,
      action.payload,
    );

    yield put(
      itemFormSlice.actions.getItemStatusResponse(
        result
          ? {
              type: "success",
              result: result,
            }
          : { type: "failure", error: { code: AppErrorCode.ITEM_NOT_FOUND } },
      ),
    );
  } catch (e: any) {
    yield put(
      itemFormSlice.actions.getItemStatusResponse({
        type: "failure",
        error: AppErrorEx.fromError(e),
      }),
    );
  }
}

function* checkItemNameAvailability(
  action: ReturnType<typeof itemFormSlice.actions.name>,
): any {
  const { itemForm }: { itemForm: ItemFormState } = yield select((s) => s);

  try {
    yield put(
      itemFormSlice.actions.nameCheckStatusResponse({ type: "running" }),
    );

    const result = yield call(
      iocContainer.get(ItemDataSource).checkNameAvailability,
      action.payload,
      itemForm.id,
    );

    yield put(
      itemFormSlice.actions.nameCheckStatusResponse({
        type: "success",
        result: result,
      }),
    );
  } catch (e: any) {
    yield put(
      itemFormSlice.actions.nameCheckStatusResponse({
        type: "failure",
        error: AppErrorEx.fromError(e),
      }),
    );
  }
}

function* saveItem(): any {
  const { itemForm }: { itemForm: ItemFormState } = yield select((s) => s);

  if (itemForm.saveStatus.type === "running") {
    return;
  }

  if (itemForm.nameCheckStatus.type != "success") {
    return yield put(
      itemFormSlice.actions.saveStatusResponse({
        type: "failure",
        error: { code: AppErrorCode.ITEM_NAME_INVALID },
      }),
    );
  }

  try {
    yield put(itemFormSlice.actions.saveStatusResponse({ type: "running" }));

    yield call(iocContainer.get(ItemDataSource).save, {
      id: itemForm.id,
      name: itemForm.name,
    });

    yield put(
      itemFormSlice.actions.saveStatusResponse({
        type: "success",
      }),
    );

    yield call(iocContainer.get(NativeBridge).send, {
      payloadName: "CancelWebBridgePayload",
    } satisfies CancelBridgePayload);
  } catch (e: any) {
    yield put(
      itemFormSlice.actions.saveStatusResponse({
        type: "failure",
        error: AppErrorEx.fromError(e),
      }),
    );
  }
}

export function* itemFormSaga() {
  yield all([
    takeLatest(itemFormSlice.actions.getItem.type, getItem),
    takeLatest(itemFormSlice.actions.name.type, checkItemNameAvailability),
    takeLeading(itemFormSlice.actions.save.type, saveItem),
  ]);
}
