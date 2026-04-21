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

      # Viewer
      ["viewer/local" "https://dev-viewer.standard.sis.se"]
      ["viewer/test" "https://viewer-tst.standard.sis.se"]
      ["viewer/dev/swagger" "https://api-dev.standard.sis.se/swagger/index.html"]

      # Mol
      ["mol/local" "https://mol-dev.sis.se"]
      ["mol-admin/local" "https://mol-admin-dev.sis.se"]

      # SD
      ["sd/local" "https://sd-api.dev.sis.se:7138/swagger/index.html"]

      # Portal
      ["portal/confluence" "https://sisswe.atlassian.net/wiki/spaces/A/pages/95289345/API-portal"]
      ["portal/jira" "https://sisswe.atlassian.net/jira/software/c/projects/API/boards/953/backlog"]
      ["portal/repos" "https://dev.azure.com/swedishinstituteforstandards/API-portal/_git/SIS.Portal.Api"]
    ];

    caesari = [
      ["gh" "https://github.com/caesariab/caesari2/pulls"]
    ];

    sports = "http://www.fawanews.sc";
    fantasy = "https://fantasy.allsvenskan.se/my-team";
    food = "https://www.cookwell.com/discover";
  };

  prefixed = builtins.concatLists (
    builtins.attrValues (builtins.mapAttrs expand bookmarks)
  );
in {
  quickmarks = {
    yt = "https://www.youtube.com";
    z = "https://mail.zoho.eu/zm/#mail/folder/inbox";
    gm = "https://mail.google.com/mail/u/0/#inbox";
    cal = "https://calendar.google.com";
    maps = "https://www.google.com/maps";
    gh = "https://github.com/jlodenius";
    ai = "https://gemini.google.com";
    rd = "https://www.reddit.com";
    ch = "https://www.chess.com";
  };

  bookmarks = builtins.concatStringsSep "\n" (map toLine prefixed);
}
