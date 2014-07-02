/*! bitbucket-widget - v0.0.1 - 2012-11-18
* Copyright (c) 2012 Adam Ahmed; Licensed MIT */

(function($, global) {
    $.fn.bitbucketRepo = function(options) {
        this.each(function() {
            makeBitbucketWidget.call(this, options);
        });
        return this;
    };
    /* Set this false if you don't want widgets initialized on ready. */
    $.fn.bitbucketRepo.loadOnDocumentReady = true;

    $(document).ready(function() {
        // allow loadOnDocumentReady to be set even if we've been lazy loaded
        // and document ready has already run.
        (global.setImmediate || global.setTimeout)(function() {
            if (!$.fn.bitbucketRepo.loadOnDocumentReady) {
                return;
            }
            $('.bitbucket-widget').bitbucketRepo();
        });
    });

    function makeBitbucketWidget(options) {
        var $el = $(this).addClass('bitbucket-widget');
        if ($el.data('bitbucket-repo-inited')) {
            return;
        }
        $el.data('bitbucket-repo-inited', true);

        var data = options && options.author && options.repo ?
            options.author + '/' + options.repo :
            $el.attr('data-repo');
        if (!data) {
            throw new Error("Either a data-repo attribute or author and repo options are required.");
        }

        var dataSplit = data.split('/');
        if (dataSplit.length !== 2) {
            throw new Error("data-repo attribute must be in 'username/repository' format.");
        }

        var author = dataSplit[0];
        var repo = dataSplit[1];
        $el.html(
            '<div class="repo-header">' +
                '<div class="repo-stats"></div>' +
                '<span class="repo-name"><a href=""></a> / <a href=""></a></span>' +
                ' <span class="repo-last-update"></span>' +
            '</div>' +
            '<div class="repo-body"></div>');
        var $header = $(':first-child', $el);
        $header.children('.repo-name')
            .children(':first-child')
                .attr('href', 'http://www.bitbucket.org/' + author)
                .attr('target', '_blank')
                .text(author)
            .end()
            .children().eq(1)
                .attr('href', 'http://www.bitbucket.org/' + data)
                .attr('target', '_blank')
                .text(repo);

        $.ajax({
            'dataType' : 'jsonp',
            //url : '/bb/repos/' + repo
            url : 'https://api.bitbucket.org/1.0/repositories/' + data
        }).done(function(repoData) {
            var $lastUpdated = $header.children('.repo-last-update');
            $lastUpdated.text(repoData.last_updated ?
                'Last updated on ' + repoData.last_updated :
                'Never updated');

            if (repoData.logo) {
                $('<img class="repo-logo" src="' + repoData.logo + '" />').insertBefore($lastUpdated);
            }

            var forks = repoData.forks_count || 0;
            var followers = repoData.followers_count || 0;
            function pluralize(num, s, p) { return num === 1 ? s : p; }
            $header.children('.repo-stats').html(
                '<div class="repo-forks" title="Has ' +
                    forks + pluralize(forks, ' fork.', ' forks.') + '">' + forks +
                '</div>' +
                '<div class="repo-followers" title="Has ' +
                    followers + pluralize(followers, ' follower.', ' followers.') + '">' + followers +
                '</div>');

            var body = '';
            if (repoData.website) {
                body += '<a class="repo-website" target="_blank" href="' + repoData.website + '">' + repoData.website + '</a>';
            }
            if (repoData.description) {
                body += '<div class="repo-description">' +
                    repoData.description.replace(/\n/g, '<br/>') + '</div>';
            }
            $el.children('.repo-body').html(body);

            $el.trigger('repo-retrieved');
        }).fail(function() {
            var guessedUrl = 'http://bitbucket.org/' + data;
            $el.children('.repo-body').html('<div class="error">There was error getting this repository\'s info. ' +
                                          'Try visiting <a target="_blank" href="' + guessedUrl + '">' + guessedUrl + '</a></div>');
        });
    }

}(jQuery, this)); // Node not supported. this != global