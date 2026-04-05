let
  toLine = pair: "${builtins.elemAt pair 1} ${builtins.elemAt pair 0}";

  bookmarks = {
    sis = [
      ["sis/repos" "https://dev.azure.com/swedishinstituteforstandards/_git/sis-frontend"]
      ["sis/teams" "https://teams.cloud.microsoft"]
      ["sis/time" "https://my355752-sso.sapbydesign.com/sap/ap/ui/repository/SAP_UI/HTMLOBERON5/client.html"]
      ["sis/jira" "https://sisswe.atlassian.net/jira/software/c/projects/SU/boards/24/backlog"]
      ["sis/azure" "https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.App%2FcontainerApps"]
      ["sis/timereport" "https://my.kleer.se/web2/time-reporting/month"]
      ["sis/viewer" "https://dev-viewer.standard.sis.se"]
      ["sis/viewer/test" "https://viewer-tst.standard.sis.se"]
      ["sis/viewer/swagger" "https://api-dev.standard.sis.se/swagger/index.html"]
      ["sis/mol" "https://mol-dev.sis.se"]
      ["sis/mol-admin" "https://mol-admin-dev.sis.se"]
    ];
    caesari = [
      ["caesari/gh" "https://github.com/caesariab/caesari2/pulls"]
    ];
    other = [
      ["sports" "http://www.fawanews.sc"]
      ["fantasy" "https://fantasy.allsvenskan.se/my-team"]
    ];
  };
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

  bookmarks =
    builtins.concatStringsSep "\n" (map toLine (builtins.concatLists (builtins.attrValues bookmarks)));
}
