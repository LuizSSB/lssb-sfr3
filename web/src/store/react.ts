import { useDispatch, useSelector } from "react-redux";
import store, { AppState } from ".";

export type AppDispatch = typeof store.dispatch;
export const useAppDispatch = useDispatch.withTypes<AppDispatch>();

export function useAppSelector<T>(selector: (s: AppState) => T): T {
  return useSelector(selector);
}
