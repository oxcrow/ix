use anyhow::ensure;
use anyhow::Result;

/// Search through identifiers in environment to find the first occurance of an identifier.
///
/// This method is intended to be used to search if an identifier exists within our compilation environment
/// and find its unique identity so we can use an efficient integer representation of the identifier
/// instead of using inefficent heap allocated strings.
///
/// Compiler development literature says we should be using a HashMap, however the literature is old.
/// Hashmaps can be slow if not implemented well and I do not want to take the risk right now.
/// It is better for us to do a linear search over a list of strings and find our intended identifer.
///
/// However this will be slow if there are too many identifiers in a file.
pub fn search_identifier<'a, 'b>(string: &'a str, strings_in_environment: &'b [&str]) -> Option<&'a str> {
    'search: for other_string in strings_in_environment.iter() {
        // Optimisation: No need to search if string lengths do not match.
        if string.len() != other_string.len() {
            continue 'search;
        }
        // Optimisation: No need to continue searching if characters do not match.
        for (a, b) in itertools::izip!(string.chars(), other_string.chars()) {
            if a != b {
                continue 'search;
            }
        }
        // We found the string!
        return Some(string);
    }
    // We found nothing :/
    None
}
