import { Container } from "inversify";
import { ItemDataSource } from "./datasources/item";

export const iocContainer = new Container();

export function loadIoCContainer() {
  iocContainer.bind(ItemDataSource).to(ItemDataSource).inSingletonScope();
}
