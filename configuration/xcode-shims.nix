{ pkgs,lib, ... }:
let
  # rg --binary --files-with-matches -F "shim" /usr/bin 2>/dev/null
  shim-programs = [
    "actool" "agvtool" "ar" "as" "asa" "bison" "bm4" "c++" "c++filt" "c89"
    "c99" "cc" "clang" "clang++" "clangd" "cmpdylib" "codesign_allocate"
    "cpp" "ctags" "ctf_insert" "DeRez" "desdp" "devicectl" "dsymutil"
    "dwarfdump" "dyld_info" "flex" "flex++" "g++" "gatherheaderdoc" "gcc"
    "gcov" "genstrings" "GetFileInfo" "git" "git-receive-pack" "git-shell"
    "git-upload-archive" "git-upload-pack" "gm4" "gnumake" "gperf"
    "hdiutil" "hdxml2manxml" "headerdoc2html" "ibtool" "ictool" "indent"
    "install_name_tool" "ld" "lex" "libtool" "lipo" "lldb" "llvm-g++"
    "llvm-gcc" "lorder" "m4" "make" "mig" "nm" "nmedit" "objdump"
    "opendiff" "otool" "pagestuff" "pip3" "python3" "ranlib" "ResMerger"
    "resolveLinks" "Rez" "rpcgen" "sdef" "sdp" "segedit" "SetFile" "size"
    "sourcekit-lsp" "SplitForks" "stapler" "strings" "strip" "swift"
    "swiftc" "tkpp" "tkpp5.34" "unifdef" "unifdefall" "usbdiagnose"
    "vtool" "xcdebug" "xcodebuild" "xcrun" "xcscontrol" "xcsdiagnose"
    "xctrace" "xed" "xml2man" "yacc"
  ];
  gen-fake-shim = prog: {
    name = "bin/${prog}";
    path = (pkgs.writeScript "fake-xcode-tool-shim-${prog}" "exit 127").out;
  };
  fake-shims = pkgs.linkFarm "hide-xcode-tool-shim" (map gen-fake-shim shim-programs);
in
{
  environment.systemPath = lib.mkForce [
    "$HOME/.nix-profile/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "${fake-shims}/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
}
