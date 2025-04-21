import { Container } from "inversify";
import { ItemDataSource } from "./datasources/ItemDataSource";
import { NativeBridge } from "./nativeBridge";

export const iocContainer = new Container();

export function loadIoCContainer() {
  iocContainer.bind(ItemDataSource).to(ItemDataSource).inSingletonScope();
  iocContainer.bind(NativeBridge).to(NativeBridge).inSingletonScope();
}
