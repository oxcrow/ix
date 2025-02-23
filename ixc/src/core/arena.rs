/// Arena interface reconfiguration
///
/// Naming scheme and organization used by bumpallo is sub-optimal.
/// Thus they have been reconfigured to be easier to understand and use.
pub mod Arena {
    pub use bumpalo::Bump as Allocator;

    pub use bumpalo::collections::String;
    pub use bumpalo::collections::Vec;

    pub use bumpalo::vec;
}
