import { Users, CreditCard, Key, TrendingUp, Shield, Zap } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

const stats = [
  { title: "Активных подписок", value: "1,247", change: "+12%", icon: Users, color: "primary" },
  { title: "Доход за месяц", value: "₽ 847,290", change: "+23%", icon: CreditCard, color: "accent" },
  { title: "Выданных ключей", value: "3,891", change: "+8%", icon: Key, color: "secondary" },
  { title: "Конверсия", value: "34.2%", change: "+5%", icon: TrendingUp, color: "primary" },
];

const recentPayments = [
  { user: "@user_alpha", plan: "Premium", amount: "₽ 990", method: "YooKassa", status: "success" },
  { user: "@crypto_fan", plan: "Ultimate", amount: "50 USDT", method: "CryptoBot", status: "success" },
  { user: "@ton_holder", plan: "Premium", amount: "15 TON", method: "TON Connect", status: "pending" },
  { user: "@vpn_user", plan: "Basic", amount: "₽ 290", method: "YooKassa", status: "success" },
];

export function Dashboard() {
  return (
    <div className="space-y-8">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat, index) => (
          <Card 
            key={stat.title} 
            className="bg-card border-border card-hover"
            style={{ animationDelay: `${index * 100}ms` }}
          >
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                {stat.title}
              </CardTitle>
              <stat.icon className={`h-5 w-5 text-${stat.color}`} />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-foreground">{stat.value}</div>
              <p className="text-xs text-accent mt-1">
                {stat.change} за последний месяц
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Payments */}
        <Card className="bg-card border-border">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <CreditCard className="h-5 w-5 text-primary" />
              Последние платежи
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentPayments.map((payment, i) => (
                <div 
                  key={i} 
                  className="flex items-center justify-between p-3 rounded-lg bg-muted/50 hover:bg-muted transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center">
                      <span className="text-primary font-mono text-sm">
                        {payment.user.slice(1, 3).toUpperCase()}
                      </span>
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{payment.user}</p>
                      <p className="text-sm text-muted-foreground">{payment.plan} • {payment.method}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-mono font-medium text-foreground">{payment.amount}</p>
                    <span className={`text-xs px-2 py-1 rounded-full ${
                      payment.status === 'success' 
                        ? 'bg-accent/20 text-accent' 
                        : 'bg-yellow-500/20 text-yellow-500'
                    }`}>
                      {payment.status === 'success' ? 'Оплачено' : 'Ожидание'}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card className="bg-card border-border">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Zap className="h-5 w-5 text-accent" />
              Быстрые действия
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <button className="w-full p-4 rounded-lg bg-primary/10 border border-primary/30 hover:bg-primary/20 transition-all group">
              <div className="flex items-center gap-3">
                <Key className="h-6 w-6 text-primary group-hover:scale-110 transition-transform" />
                <div className="text-left">
                  <p className="font-medium text-foreground">Сгенерировать ключ</p>
                  <p className="text-sm text-muted-foreground">Создать новый VLESS ключ</p>
                </div>
              </div>
            </button>
            
            <button className="w-full p-4 rounded-lg bg-secondary/10 border border-secondary/30 hover:bg-secondary/20 transition-all group">
              <div className="flex items-center gap-3">
                <Users className="h-6 w-6 text-secondary group-hover:scale-110 transition-transform" />
                <div className="text-left">
                  <p className="font-medium text-foreground">Добавить пользователя</p>
                  <p className="text-sm text-muted-foreground">Вручную добавить подписку</p>
                </div>
              </div>
            </button>
            
            <button className="w-full p-4 rounded-lg bg-accent/10 border border-accent/30 hover:bg-accent/20 transition-all group">
              <div className="flex items-center gap-3">
                <Shield className="h-6 w-6 text-accent group-hover:scale-110 transition-transform" />
                <div className="text-left">
                  <p className="font-medium text-foreground">Проверить сервер</p>
                  <p className="text-sm text-muted-foreground">Статус VPN серверов</p>
                </div>
              </div>
            </button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
