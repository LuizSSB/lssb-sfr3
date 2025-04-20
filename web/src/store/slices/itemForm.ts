import { createSlice } from "@reduxjs/toolkit";
import { call, put, takeLatest } from "redux-saga/effects";
import { ItemDataSource } from "../../datasources/item";
import { iocContainer } from "../../ioc";
import { ActionStatus } from "../../models/utils/ActionStatus";

type ItemFormState = {
  name: string;
  nameCheckStatus: ActionStatus<{ allowed: boolean }>;
};

export const itemFormSlice = createSlice({
  name: "itemForm",
  initialState: <ItemFormState>{
    name: "",
    nameCheckStatus: { type: "none" },
  },
  reducers: {
    name(state, action: { payload: string }) {
      state.name = action.payload;
    },
    nameCheckStatusResponse(
      state,
      action: { payload: ItemFormState["nameCheckStatus"] },
    ) {
      state.nameCheckStatus = action.payload;
      switch (action.payload.type) {
        case "success":
          action.payload.result;
      }
    },
  },
});

function* checkUsernameAvailability(
  action: ReturnType<typeof itemFormSlice.actions.name>,
): any {
  try {
    yield put(
      itemFormSlice.actions.nameCheckStatusResponse({ type: "fetching" }),
    );

    const itemDataSource = iocContainer.get(ItemDataSource);
    const result = yield call(
      itemDataSource.checkNameAvailability,
      action.payload,
    );
    console.log("result", result);

    yield put(
      itemFormSlice.actions.nameCheckStatusResponse({
        type: "success",
        result: result,
      }),
    );
  } catch (e: any) {
    itemFormSlice.actions.nameCheckStatusResponse({
      type: "failure",
      error: e,
    });
  }
}

export function* itemFormSaga() {
  yield takeLatest(itemFormSlice.actions.name.type, checkUsernameAvailability);
}
