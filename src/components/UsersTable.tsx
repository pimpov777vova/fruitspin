import { useState } from "react";
import { Search, Filter, MoreVertical, Key, Ban, Mail } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const mockUsers = [
  { id: 1, username: "@alexander_dev", telegramId: "123456789", plan: "Ultimate", status: "active", expires: "2024-03-15", keys: 3 },
  { id: 2, username: "@maria_vpn", telegramId: "987654321", plan: "Premium", status: "active", expires: "2024-02-28", keys: 2 },
  { id: 3, username: "@crypto_user", telegramId: "456789123", plan: "Basic", status: "expired", expires: "2024-01-10", keys: 1 },
  { id: 4, username: "@ton_fan", telegramId: "789123456", plan: "Premium", status: "active", expires: "2024-04-01", keys: 2 },
  { id: 5, username: "@secure_net", telegramId: "321654987", plan: "Ultimate", status: "active", expires: "2024-03-20", keys: 5 },
];

export function UsersTable() {
  const [search, setSearch] = useState("");

  const filteredUsers = mockUsers.filter(user => 
    user.username.toLowerCase().includes(search.toLowerCase()) ||
    user.telegramId.includes(search)
  );

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold gradient-text">Пользователи</h2>
          <p className="text-muted-foreground">Управление подписками и ключами</p>
        </div>
        <Button variant="cyber">
          + Добавить вручную
        </Button>
      </div>

      {/* Search & Filter */}
      <Card className="bg-card border-border">
        <CardContent className="py-4">
          <div className="flex gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Поиск по username или Telegram ID..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-10 bg-muted border-border"
              />
            </div>
            <Button variant="outline" className="gap-2">
              <Filter className="h-4 w-4" />
              Фильтры
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Users Table */}
      <Card className="bg-card border-border">
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-border">
                  <th className="text-left p-4 text-muted-foreground font-medium">Пользователь</th>
                  <th className="text-left p-4 text-muted-foreground font-medium">Telegram ID</th>
                  <th className="text-left p-4 text-muted-foreground font-medium">Тариф</th>
                  <th className="text-left p-4 text-muted-foreground font-medium">Статус</th>
                  <th className="text-left p-4 text-muted-foreground font-medium">Истекает</th>
                  <th className="text-left p-4 text-muted-foreground font-medium">Ключей</th>
                  <th className="text-left p-4 text-muted-foreground font-medium">Действия</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user) => (
                  <tr key={user.id} className="border-b border-border/50 hover:bg-muted/30 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
                          <span className="text-primary-foreground font-medium">
                            {user.username.slice(1, 3).toUpperCase()}
                          </span>
                        </div>
                        <span className="font-medium text-foreground">{user.username}</span>
                      </div>
                    </td>
                    <td className="p-4">
                      <code className="text-sm text-muted-foreground font-mono">{user.telegramId}</code>
                    </td>
                    <td className="p-4">
                      <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                        user.plan === 'Ultimate' ? 'bg-secondary/20 text-secondary' :
                        user.plan === 'Premium' ? 'bg-primary/20 text-primary' :
                        'bg-muted text-muted-foreground'
                      }`}>
                        {user.plan}
                      </span>
                    </td>
                    <td className="p-4">
                      <span className={`flex items-center gap-2 ${
                        user.status === 'active' ? 'text-accent' : 'text-destructive'
                      }`}>
                        <span className={`w-2 h-2 rounded-full ${
                          user.status === 'active' ? 'bg-accent' : 'bg-destructive'
                        }`} />
                        {user.status === 'active' ? 'Активен' : 'Истёк'}
                      </span>
                    </td>
                    <td className="p-4 text-muted-foreground">{user.expires}</td>
                    <td className="p-4 text-foreground">{user.keys}</td>
                    <td className="p-4">
                      <div className="flex items-center gap-2">
                        <Button size="icon" variant="ghost" className="h-8 w-8">
                          <Key className="h-4 w-4" />
                        </Button>
                        <Button size="icon" variant="ghost" className="h-8 w-8">
                          <Mail className="h-4 w-4" />
                        </Button>
                        <Button size="icon" variant="ghost" className="h-8 w-8 text-destructive">
                          <Ban className="h-4 w-4" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
