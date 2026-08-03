#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <filesystem>
#include <string>

#include "flutter_window.h"
#include "utils.h"

namespace {

void AttachConsoleForDiagnostics() {
  if (::AttachConsole(ATTACH_PARENT_PROCESS)) {
    return;
  }

  if (::IsDebuggerPresent()) {
    CreateAndAttachConsole();
    return;
  }

  // Do not create or wait on a hidden console here. Some Windows installs fail
  // to attach to that temporary console, which blocks the Flutter window from
  // ever being created.
}

std::wstring GetExecutableDirectory() {
  wchar_t path[MAX_PATH];
  DWORD length = ::GetModuleFileNameW(nullptr, path, MAX_PATH);
  if (length == 0 || length == MAX_PATH) {
    return L".";
  }

  return std::filesystem::path(path).parent_path().wstring();
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to an existing console when launched from a terminal, or create one
  // only under a debugger. Release launches must continue straight to Flutter.
  AttachConsoleForDiagnostics();

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(GetExecutableDirectory() + L"\\data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"TwigaMoney", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
