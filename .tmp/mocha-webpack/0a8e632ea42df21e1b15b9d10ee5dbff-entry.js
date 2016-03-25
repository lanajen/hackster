
    var testsContext = require.context("../../spec/javascripts/unit", false);

    var runnable = testsContext.keys();

    runnable.forEach(testsContext);
    