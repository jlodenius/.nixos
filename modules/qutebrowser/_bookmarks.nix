let
  toLine = pair: "${builtins.elemAt pair 1} ${builtins.elemAt pair 0}";

  expand = name: value:
    if builtins.isList value
    then map (pair: ["${name}/${builtins.elemAt pair 0}" (builtins.elemAt pair 1)]) value
    else [[name value]];

  bookmarks = {
    sis = [
      ["repos" "https://dev.azure.com/swedishinstituteforstandards/_git/sis-frontend"]
      ["teams" "https://teams.cloud.microsoft"]
      ["time" "https://my355752-sso.sapbydesign.com/sap/ap/ui/repository/SAP_UI/HTMLOBERON5/client.html"]
      ["jira" "https://sisswe.atlassian.net/jira/software/c/projects/SU/boards/24/backlog"]
      ["azure" "https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.App%2FcontainerApps"]
      ["timereport" "https://my.kleer.se/web2/time-reporting/month"]
      ["viewer" "https://dev-viewer.standard.sis.se"]
      ["viewer/test" "https://viewer-tst.standard.sis.se"]
      ["viewer/swagger" "https://api-dev.standard.sis.se/swagger/index.html"]
      ["mol" "https://mol-dev.sis.se"]
      ["mol-admin" "https://mol-admin-dev.sis.se"]
      ["sd-local" "https://sd-api.dev.sis.se:7138/swagger/index.html"]
    ];
    caesari = [
      ["gh" "https://github.com/caesariab/caesari2/pulls"]
    ];

    sports = "http://www.fawanews.sc";
    fantasy = "https://fantasy.allsvenskan.se/my-team";
  };

  prefixed = builtins.concatLists (
    builtins.attrValues (builtins.mapAttrs expand bookmarks)
  );
in {
  quickmarks = {
    yt = "https://www.youtube.com";
    z = "https://mail.zoho.eu/zm/#mail/folder/inbox";
    gm = "https://mail.google.com/mail/u/0/#inbox";
    gh = "https://github.com/jlodenius";
    maps = "https://www.google.com/maps";
    ai = "https://gemini.google.com";
    rd = "https://www.reddit.com";
    ch = "https://www.chess.com";
  };

  bookmarks = builtins.concatStringsSep "\n" (map toLine prefixed);
}
