export enum AppErrorCode {
  UNKNOWN = -1,

  ITEM_NOT_FOUND = 1,
  ITEM_NAME_INVALID = 2,
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
