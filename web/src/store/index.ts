import { configureStore } from "@reduxjs/toolkit";
import createSagaMiddleware from "redux-saga";
import { all, fork } from "redux-saga/effects";
import { itemFormSaga, itemFormSlice } from "./slices/itemFormSlice";

const sagaMiddleware = createSagaMiddleware();

const store = configureStore({
  reducer: {
    itemForm: itemFormSlice.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(sagaMiddleware),
});

const rootSaga = function* () {
  yield all([fork(itemFormSaga)]);
};

sagaMiddleware.run(rootSaga);

export type AppState = ReturnType<typeof store.getState>;

export default store;
