export class ItemDataSource {
  getItem = async (id: string): Promise<Item | undefined> => {
    return {
      id: "2323",
      name: "dubdub",
    };
  };

  checkNameAvailability = async (
    name: string,
  ): Promise<{ available: boolean }> => {
    return { available: false };
  };

  save = async (item: Omit<Item, "id"> | { id?: string }) => {};
}
