import Foundation

public enum SyncStatus: String, Sendable {
    case localOnly = "Local Storage (Development Mode)"
    case connected = "Connected to Supabase"
    case syncing = "Synchronizing..."
    case offline = "Offline (Local Cache Active)"
}

public struct SupabaseConfig: Sendable {
    public static let isConfigured: Bool = false
    public static let currentStatus: SyncStatus = .localOnly

    // Configuration template for future remote sync activation
    public static let setupInstructions = """
    Daymark is currently running in full Native Local Storage mode.
    All data is persisted safely on device in the Application Support directory.

    To enable Supabase remote sync when ready:
    1. Create a Supabase project at https://database.new
    2. Run the migration schema located in `docs/SUPABASE_SETUP.md`
    3. Provide your SUPABASE_URL and SUPABASE_ANON_KEY securely via DaymarkConfig or Keychain.
    4. Enable Row Level Security (RLS) as defined in the documentation.
    """
}
