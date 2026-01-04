return {
  "itchyny/lightline.vim",
  lazy = false,
  config = function()
    -- no need to also show mode in cmd line when we have bar
    vim.o.showmode = false
    vim.g.lightline = {
      active = {
        left = {
          { "mode", "paste" },
          { "readonly", "filename", "modified" },
        },
        right = {
          { "lineinfo" },
          { "percent" },
          { "fileencoding", "filetype" },
        },
      },
      component_function = {
        filename = "LightlineFilename",
      },
    }
    function LightlineFilenameInLua()
      if vim.fn.expand("%:t") == "" then
        return "[No Name]"
      else
        return vim.fn.getreg("%")
      end
    end
    vim.cmd(
      [[
				function! g:LightlineFilename()
					return v:lua.LightlineFilenameInLua()
				endfunction
				]],
      true
    )
  end,
}
