export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      courses: {
        Row: {
          brochure_url: string | null
          category: string
          created_at: string | null
          created_by: string | null
          description: string | null
          duration: string | null
          highlights: string[] | null
          id: string
          image_url: string | null
          is_active: boolean | null
          is_popular: boolean | null
          level: string | null
          slug: string
          title: string
          updated_at: string | null
        }
        Insert: {
          brochure_url?: string | null
          category: string
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          duration?: string | null
          highlights?: string[] | null
          id?: string
          image_url?: string | null
          is_active?: boolean | null
          is_popular?: boolean | null
          level?: string | null
          slug: string
          title: string
          updated_at?: string | null
        }
        Update: {
          brochure_url?: string | null
          category?: string
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          duration?: string | null
          highlights?: string[] | null
          id?: string
          image_url?: string | null
          is_active?: boolean | null
          is_popular?: boolean | null
          level?: string | null
          slug?: string
          title?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "courses_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      enrollments: {
        Row: {
          completed_at: string | null
          course_id: string
          enrolled_at: string | null
          id: string
          status: string | null
          student_id: string
        }
        Insert: {
          completed_at?: string | null
          course_id: string
          enrolled_at?: string | null
          id?: string
          status?: string | null
          student_id: string
        }
        Update: {
          completed_at?: string | null
          course_id?: string
          enrolled_at?: string | null
          id?: string
          status?: string | null
          student_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "enrollments_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "enrollments_student_id_fkey"
            columns: ["student_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      leads: {
        Row: {
          assigned_to: string | null
          country: string | null
          course_id: string | null
          created_at: string | null
          email: string
          id: string
          inquiry_type: string
          message: string | null
          name: string
          notes: string | null
          phone: string
          source: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          assigned_to?: string | null
          country?: string | null
          course_id?: string | null
          created_at?: string | null
          email: string
          id?: string
          inquiry_type: string
          message?: string | null
          name: string
          notes?: string | null
          phone: string
          source?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          assigned_to?: string | null
          country?: string | null
          course_id?: string | null
          created_at?: string | null
          email?: string
          id?: string
          inquiry_type?: string
          message?: string | null
          name?: string
          notes?: string | null
          phone?: string
          source?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "leads_assigned_to_fkey"
            columns: ["assigned_to"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "leads_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string | null
          email: string
          full_name: string | null
          id: string
          phone: string | null
          role: string
          updated_at: string | null
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string | null
          email: string
          full_name?: string | null
          id: string
          phone?: string | null
          role?: string
          updated_at?: string | null
        }
        Update: {
          avatar_url?: string | null
          created_at?: string | null
          email?: string
          full_name?: string | null
          id?: string
          phone?: string | null
          role?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      video_promos: {
        Row: {
          course_id: string | null
          created_at: string | null
          display_order: number | null
          duration: string | null
          id: string
          is_active: boolean | null
          is_featured: boolean | null
          subtitle: string | null
          thumbnail_url: string | null
          title: string
          type: string
          updated_at: string | null
          vimeo_id: string
        }
        Insert: {
          course_id?: string | null
          created_at?: string | null
          display_order?: number | null
          duration?: string | null
          id?: string
          is_active?: boolean | null
          is_featured?: boolean | null
          subtitle?: string | null
          thumbnail_url?: string | null
          title: string
          type: string
          updated_at?: string | null
          vimeo_id: string
        }
        Update: {
          course_id?: string | null
          created_at?: string | null
          display_order?: number | null
          duration?: string | null
          id?: string
          is_active?: boolean | null
          is_featured?: boolean | null
          subtitle?: string | null
          thumbnail_url?: string | null
          title?: string
          type?: string
          updated_at?: string | null
          vimeo_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "video_promos_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      create_lead: {
        Args: {
          p_country: string
          p_course_id: string
          p_email: string
          p_inquiry_type: string
          p_message: string
          p_name: string
          p_phone: string
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
