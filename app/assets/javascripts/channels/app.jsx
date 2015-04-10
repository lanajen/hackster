var router = Router.create({
//   location: Router.HistoryLocation,
  routes: routes
});

var stores = {
  comment: new CommentStore(),
  route: new RouteStore({ router: router }),
  thought: new ThoughtStore(),
  user: new UserStore()
};

var flux = new Fluxxor.Flux(stores, actions.methods);
flux.on("dispatch", function(type, payload) {
  console.log("Dispatch:", type, payload);
});

router.run(function(Handler) {
  React.render(
    <Handler flux={flux} />,
    document.getElementById('react-container')
  );
});