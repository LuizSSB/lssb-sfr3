export class ItemDataSource {
  checkNameAvailability = async (
    name: string,
  ): Promise<{ available: boolean }> => {
    return { available: false };
  };

  save = async (item: Item) => {};
}
