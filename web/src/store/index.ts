import { configureStore } from "@reduxjs/toolkit";
import { useDispatch } from "react-redux";
import createSagaMiddleware from "redux-saga";
import { all, fork } from "redux-saga/effects";
import { itemFormSaga, itemFormSlice } from "./slices/itemForm";

const sagaMiddleware = createSagaMiddleware();

const store = configureStore({
  reducer: {
    itemFormSlice: itemFormSlice.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(sagaMiddleware),
});

const rootSaga = function* () {
  yield all([fork(itemFormSaga)]);
};

sagaMiddleware.run(rootSaga);

export type AppState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
export const useAppDispatch = useDispatch.withTypes<AppDispatch>();

export default store;
