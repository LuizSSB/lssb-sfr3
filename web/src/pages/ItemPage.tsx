import {
  IonAlert,
  IonButton,
  IonButtons,
  IonContent,
  IonHeader,
  IonInput,
  IonItem,
  IonItemGroup,
  IonList,
  IonPage,
  IonProgressBar,
  IonTitle,
  IonToolbar,
} from "@ionic/react";
import { useEffect, useMemo } from "react";
import { useParams } from "react-router";
import { AppErrorCode } from "../models/utils/AppError";
import { useAppDispatch, useAppSelector } from "../store/react";
import { itemFormSlice } from "../store/slices/itemFormSlice";
import "./ItemPage.css";
import { PageFCEx } from "./utils";

type Params = {
  id?: string;
};

const ItemFormHeaderToolbar: React.FC<Params> = ({ id }) => {
  const getItemStatus = useAppSelector((s) => s.itemForm.getItemStatus);
  const saveStatus = useAppSelector((s) => s.itemForm.saveStatus);
  const dispatch = useAppDispatch();

  const title = useMemo(() => {
    switch (getItemStatus.type) {
      case "none":
      case "fetching":
      case "failure":
        return "Preparing";
      case "success":
        return getItemStatus.result?.name ?? "Add new Item";
    }
  }, [getItemStatus]);

  const getItemError = useMemo(() => {
    if (getItemStatus.type === "failure") {
      return `Failed to get item. ${getItemStatus.error?.code ? `Code ${AppErrorCode[getItemStatus.error.code!]}. ` : ""}Try again.`;
    }
    return undefined;
  }, [getItemStatus.type === "failure"]);

  const saveError = useMemo(() => {
    if (saveStatus.type === "failure") {
      return `Save failed. ${saveStatus.error?.code ? `Code ${AppErrorCode[saveStatus.error.code!]}. ` : ""}Try again.`;
    }
    return undefined;
  }, [saveStatus.type === "failure"]);

  return (
    <>
      <IonToolbar>
        <IonTitle>{title}</IonTitle>
        <IonButtons slot="end">
          <IonButton
            disabled={[getItemStatus.type, saveStatus.type].includes(
              "fetching",
            )}
            onClick={() => dispatch(itemFormSlice.actions.save())}
          >
            Save
          </IonButton>
        </IonButtons>
        {[getItemStatus.type, saveStatus.type].includes("fetching") && (
          <IonProgressBar type="indeterminate" />
        )}
      </IonToolbar>
      <IonAlert
        isOpen={!!getItemError}
        onDidDismiss={(e) =>
          dispatch(itemFormSlice.actions.saveStatusResponse({ type: "none" }))
        }
        header="Failure"
        buttons={[
          {
            text: "Cancel",
            role: "cancel",
            handler() {},
          },
          {
            text: "Try again",
            handler() {
              dispatch(itemFormSlice.actions.getItem(id!));
            },
          },
        ]}
        message={saveError}
      />
      <IonAlert
        isOpen={!!saveError}
        onDidDismiss={(e) => {
          console.log("e", e);
          dispatch(itemFormSlice.actions.saveStatusResponse({ type: "none" }));
        }}
        header="Failure"
        buttons={["Dismiss"]}
        message={saveError}
      />
    </>
  );
};

const ItemFormNameField: React.FC = () => {
  const name = useAppSelector((s) => s.itemForm.name);
  const isDisabled = useAppSelector(
    (s) =>
      s.itemForm.getItemStatus.type !== "success" ||
      s.itemForm.saveStatus.type === "fetching",
  );
  const dispatch = useAppDispatch();

  return (
    <IonInput
      label="Name"
      placeholder="Enter text"
      value={name}
      onIonInput={(e) => {
        dispatch(itemFormSlice.actions.name(e.detail.value?.toString() ?? ""));
      }}
      disabled={isDisabled}
    />
  );
};

const ItemPage: React.FC<Params> = ({ id }) => {
  const dispatch = useAppDispatch();

  useEffect(() => {
    dispatch(
      id
        ? itemFormSlice.actions.getItem(id)
        : itemFormSlice.actions.getItemStatusResponse({ type: "success" }),
    );
  }, [id]);

  return (
    <IonPage>
      <IonHeader>
        <ItemFormHeaderToolbar />
      </IonHeader>
      <IonContent fullscreen>
        <IonList>
          <IonItemGroup>
            <IonItem>
              <ItemFormNameField />
            </IonItem>
          </IonItemGroup>
        </IonList>
      </IonContent>
    </IonPage>
  );
};

export const NewItemPage = PageFCEx.declare(ItemPage, "/item", () => "/item");

export const EditItemPage = PageFCEx.declare(
  () => {
    const params: Params = useParams();
    return ItemPage({ id: params.id });
  },
  "/item/:id",
  (p: { id: string }) => `/item/${p.id}`,
);
