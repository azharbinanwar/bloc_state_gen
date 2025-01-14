#### 0.1.0
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
