export enum AppErrorCode {
  UNKNOWN = -1,

  WEB_BRIDGE_UNAVAILABLE = 1,

  INVALID_FORMAT = 100,

  ITEM_NOT_FOUND = 200,
  ITEM_NAME_INVALID = 201,
}

export type AppError = Readonly<{
  code?: AppErrorCode;
  message?: string;
}>;

export class AppErrorError extends Error {
  constructor(
    public code?: AppErrorCode,
    message?: string,
  ) {
    super(message);
  }
}

export const AppErrorEx = {
  fromError(e: Error): AppError {
    if (e instanceof AppErrorError) {
      return { code: e.code, message: e.message };
    }
    return { code: AppErrorCode.UNKNOWN, message: e.message };
  },
};
