import { AppError } from "./AppError";

export type ActionStatus<TSuccess = undefined> =
  | { type: "none" | "running" }
  | ({ type: "success" } & (TSuccess extends undefined
      ? {
          result?: TSuccess;
        }
      : { result: TSuccess }))
  | {
      type: "failure";
      error: AppError;
    };
