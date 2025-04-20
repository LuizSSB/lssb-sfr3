export type ActionStatus<TSuccess> =
  | { type: "none" | "fetching" }
  | {
      type: "success";
      result: TSuccess;
    }
  | {
      type: "failure";
      error: Error;
    };
