export type PageFC<
  S = {},
  TParams extends { [key: string]: string } = {},
> = React.FC<S> & {
  route: string;
  routeForParams(params: TParams): string;
};

export const PageFCEx = {
  declare<S = {}, TParams extends { [key: string]: string } = {}>(
    fc: React.FC<S>,
    route: string,
    routeForParams: (params: TParams) => string,
  ): PageFC<S, TParams> {
    const pageFC: PageFC<S, TParams> = fc as any;
    pageFC.route = route;
    pageFC.routeForParams = routeForParams;
    return pageFC;
  },
};
