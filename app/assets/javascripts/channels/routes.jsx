var routes = (
  <Route handler={EmptyView} name="home" path="/">
    <Route handler={ThoughtPage} name="thought" path="posts/:id" />
    <Route handler={ChannelContainer} name="hashtag" path="/hashtags/:hashtag" />
    <DefaultRoute handler={ChannelContainer} />
    <NotFoundRoute handler={NotFound} />
  </Route>
);
