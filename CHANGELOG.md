### 1.0.0
- feat!: move annotation target from state to bloc/cubit class
- feat: support state classes defined inside bloc/cubit, HydratedCubit/Bloc, ReplayCubit/Bloc classes
- fix: update deprecated analyzer API usage (enclosingElement3)
- fix: improve nested class detection
- fix: enhance error handling for missing state classes
- docs: update README with new inline state definition examples
- docs: add migration guide for 1.0.0
- chore: update minimum Dart SDK version to 2.17.0
- chore: upgrade analyzer dependency

#### 0.1.1+3
- **Documentation Updates**:
  - Fixed dead example link in the `README.md`.
  - Removed the contribution guide section from the `README.md`.
  - Added a video example to the `README.md` for better understanding.

#### 0.1.0+2
- **Update** `_getParameterName` function:
    - Converts a class name to a parameter name in camelCase.
    - Cleans class names by removing common suffixes like `State`, `Bloc`, and `Cubit`.
    - Handles standardized names for common state types (e.g., `Loading` becomes `onLoading`).
    - Removes the parent class name prefix for custom states and converts them to camelCase.
      **Examples:**
    - `LoadingState` → `onLoading`
    - `AuthenticatedUserState` → `onAuthenticated`
    - `SuccessBloc` → `onSuccess`
    - `CustomError` → `onCustomError`

#### 0.0.1
- Initial release
- Support for generating state extensions
- Match pattern support
- Logging utilities
